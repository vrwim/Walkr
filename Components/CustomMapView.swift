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
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        
        mapView.showsUserLocation = true
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        
        view.removeOverlays(view.overlays)
        view.addOverlays(overlays.filter { $0.enabled })
        
        if let moveTo {
            view.visibleMapRect = moveTo
            self.moveTo = nil
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            return ImageOverlayRenderer(overlay: overlay)
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            parent.visibleMapRect = mapView.visibleMapRect
        }
        
        init(_ parent: CustomMapView) {
            self.parent = parent
        }
    }
    
    class ImageOverlayRenderer: MKOverlayRenderer {
        override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
            guard let overlay = overlay as? ImageOverlay else {
                return
            }
            
            let rect = self.rect(for: overlay.boundingMapRect)
            
            context.scaleBy(x: 1.0, y: -1.0)
            context.translateBy(x: 0.0, y: -rect.size.height)
            context.draw(overlay.image.cgImage!, in: rect)
        }
    }
}
