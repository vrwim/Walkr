//
//  CustomMapView.swift
//  Walkr (iOS)
//
//  Created by Wim Van Renterghem on 22/03/2021.
//

import SwiftUI
import MapKit

struct CustomMapView: UIViewRepresentable {
    @Binding var overlays: [ImageOverlay]
    @Binding var visibleMapRect: MKMapRect
    @Binding var moveTo: MKMapRect?

    // When non-nil the map is in fine-tune mode: corner annotations are shown for this overlay.
    var fineTuningOverlay: ImageOverlay?
    var overlayOpacity: Double = 1.0
    var onCornerMoved: ((Int, CLLocationCoordinate2D) -> Void)?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()

        mapView.showsUserLocation = true
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false

        mapView.delegate = context.coordinator
        mapView.register(CornerAnnotationView.self, forAnnotationViewWithReuseIdentifier: CornerAnnotationView.reuseIdentifier)
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        // Update the opacity in the coordinator so renderers can access it
        context.coordinator.overlayOpacity = overlayOpacity
        
        view.removeOverlays(view.overlays)
        
        // Add overlays, but if we're fine-tuning one, only add that one
        // (This ensures it renders even if there are issues with the regular rendering path)
        let overlaysToAdd: [ImageOverlay]
        if let fineTuning = fineTuningOverlay {
            overlaysToAdd = [fineTuning]
        } else {
            overlaysToAdd = overlays.filter { $0.enabled }
        }
        view.addOverlays(overlaysToAdd)
        
        // Update alpha for all existing renderers
        for overlay in view.overlays {
            if let renderer = view.renderer(for: overlay) {
                renderer.alpha = CGFloat(overlayOpacity)
            }
        }

        if let moveTo {
            view.setVisibleMapRect(moveTo, animated: false)
            // Use async to avoid "Publishing changes from within view updates" warning
            DispatchQueue.main.async {
                self.moveTo = nil
            }
        }

        // Sync corner annotations for fine-tune mode
        let existingCornerAnnotations = view.annotations.compactMap { $0 as? CornerAnnotation }

        if let overlay = fineTuningOverlay {
            // Add or update 4 corner annotations
            let corners = overlay.cornersArray
            if existingCornerAnnotations.count == 4,
               existingCornerAnnotations.allSatisfy({ $0.overlay === overlay }) {
                // Already present — update coordinates in case corners moved programmatically
                for ann in existingCornerAnnotations {
                    ann.updateCoordinate(corners[ann.cornerIndex].coordinate)
                }
            } else {
                view.removeAnnotations(existingCornerAnnotations)
                let annotations = (0..<4).map { CornerAnnotation(cornerIndex: $0, overlay: overlay) }
                view.addAnnotations(annotations)
            }
        } else {
            // Not in fine-tune mode — remove all corner annotations
            view.removeAnnotations(existingCornerAnnotations)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView
        var overlayOpacity: Double = 1.0

        init(_ parent: CustomMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let imageOverlay = overlay as? ImageOverlay else {
                return MKOverlayRenderer(overlay: overlay)
            }
            let renderer = ImageOverlayRenderer(overlay: imageOverlay)
            renderer.alpha = CGFloat(overlayOpacity)
            return renderer
        }

        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            parent.visibleMapRect = mapView.visibleMapRect
        }

        // MARK: Annotation views

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard annotation is CornerAnnotation else { return nil }
            return mapView.dequeueReusableAnnotationView(withIdentifier: CornerAnnotationView.reuseIdentifier, for: annotation)
        }

        // Called continuously while dragging
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
            guard let cornerAnnotation = view.annotation as? CornerAnnotation else { return }

            switch newState {
            case .dragging, .ending:
                parent.onCornerMoved?(cornerAnnotation.cornerIndex, cornerAnnotation.coordinate)
            default:
                break
            }
        }
    }

    // MARK: - Perspective Image Renderer

    class ImageOverlayRenderer: MKOverlayRenderer {
        // Cache: avoid rerunning CIFilter every draw when nothing changed
        private var cachedCGImage: CGImage?
        private var cachedCorners: [MKMapPoint] = []
        private var cachedZoomScale: MKZoomScale = 0
        
        override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
            guard let overlay = overlay as? ImageOverlay,
                  let cgImage = overlay.image.cgImage else { return }

            let corners = overlay.cornersArray
            
            // Convert map corners to points in the renderer's coordinate system
            let tl = point(for: corners[0])
            let tr = point(for: corners[1])
            let bl = point(for: corners[2])
            let br = point(for: corners[3])
            
            // Compute bounding rect of the 4 CGPoints
            let minX = min(tl.x, tr.x, bl.x, br.x)
            let minY = min(tl.y, tr.y, bl.y, br.y)
            let maxX = max(tl.x, tr.x, bl.x, br.x)
            let maxY = max(tl.y, tr.y, bl.y, br.y)
            
            // The width/height are in "points", but we need pixels
            // MKOverlayRenderer's coordinate space is in "map points per pixel"
            // So we multiply by zoomScale to get actual drawable size
            let originalWidth = (maxX - minX) * CGFloat(zoomScale)
            let originalHeight = (maxY - minY) * CGFloat(zoomScale)
            var boundingSize = CGSize(width: originalWidth, height: originalHeight)
            
            // CRITICAL FIX: Core Image can't handle massive images. Cap at reasonable size.
            let maxDimension: CGFloat = 4096 // Reduced for better performance
            var renderScale: CGFloat = 1.0
            if boundingSize.width > maxDimension || boundingSize.height > maxDimension {
                renderScale = min(maxDimension / boundingSize.width, maxDimension / boundingSize.height)
                boundingSize = CGSize(width: boundingSize.width * renderScale, 
                                     height: boundingSize.height * renderScale)
            }
            
            // Validate bounding size
            guard boundingSize.width > 1,
                  boundingSize.height > 1,
                  boundingSize.width.isFinite,
                  boundingSize.height.isFinite else {
                return
            }

            // Compute local corners (relative to bounding rect, in the scaled pixel space)
            let scaleToPixels = CGFloat(zoomScale) * renderScale
            let localTL = CGPoint(x: (tl.x - minX) * scaleToPixels, 
                                 y: (tl.y - minY) * scaleToPixels)
            let localTR = CGPoint(x: (tr.x - minX) * scaleToPixels, 
                                 y: (tr.y - minY) * scaleToPixels)
            let localBL = CGPoint(x: (bl.x - minX) * scaleToPixels, 
                                 y: (bl.y - minY) * scaleToPixels)
            let localBR = CGPoint(x: (br.x - minX) * scaleToPixels, 
                                 y: (br.y - minY) * scaleToPixels)

            // Use cached image when nothing has changed
            let warpedCGImage: CGImage
            if cachedZoomScale == zoomScale,
               cachedCorners.count == 4,
               zip(cachedCorners, corners).allSatisfy({ $0.x == $1.x && $0.y == $1.y }),
               let cached = cachedCGImage {
                warpedCGImage = cached
            } else {
                guard let warped = perspectiveWarp(source: cgImage,
                                                   outputSize: boundingSize,
                                                   tl: localTL, tr: localTR,
                                                   bl: localBL, br: localBR) else { return }
                warpedCGImage = warped
                cachedCGImage = warped
                cachedCorners = corners
                cachedZoomScale = zoomScale
            }

            // Draw in the map's coordinate system (not pixels)
            let drawRect = CGRect(x: minX, y: minY, 
                                width: maxX - minX, 
                                height: maxY - minY)

            // The CGContext in MKOverlayRenderer is y-up (flipped vs UIKit).
            context.saveGState()
            context.translateBy(x: drawRect.minX, y: drawRect.minY + drawRect.height)
            context.scaleBy(x: 1, y: -1)
            context.draw(warpedCGImage, in: CGRect(origin: .zero, size: drawRect.size))
            context.restoreGState()
        }

        /// Warp `source` image so its 4 corners land on the given CGPoints within an image of `outputSize`.
        /// Uses CIFilter "CIPerspectiveTransform".
        private func perspectiveWarp(source: CGImage,
                                     outputSize: CGSize,
                                     tl: CGPoint, tr: CGPoint,
                                     bl: CGPoint, br: CGPoint) -> CGImage? {
            // Validate output size before creating CIImage
            guard outputSize.width > 1, outputSize.height > 1,
                  outputSize.width.isFinite, outputSize.height.isFinite else {
                print("⚠️ Invalid outputSize for perspective warp: \(outputSize)")
                return nil
            }
            
            let ciImage = CIImage(cgImage: source)

            // CIFilter coordinate system is y-up, so flip Y relative to outputSize.height
            func flip(_ p: CGPoint) -> CIVector {
                CIVector(x: p.x, y: outputSize.height - p.y)
            }

            guard let filter = CIFilter(name: "CIPerspectiveTransform") else { return nil }
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(flip(tl), forKey: "inputTopLeft")
            filter.setValue(flip(tr), forKey: "inputTopRight")
            filter.setValue(flip(bl), forKey: "inputBottomLeft")
            filter.setValue(flip(br), forKey: "inputBottomRight")

            guard let outputCIImage = filter.outputImage else { return nil }

            let ciContext = CIContext(options: [.useSoftwareRenderer: false])
            let renderRect = CGRect(origin: .zero, size: outputSize)
            return ciContext.createCGImage(outputCIImage, from: renderRect)
        }
    }
}
