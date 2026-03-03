//
//  MapView.swift
//  Walkr
//
//  Created by Wim Van Renterghem on 12/03/2021.
//

import SwiftUI
import MapKit

extension View {
    func andPrint(_ val: Any) -> some View {
        print(val)
        return self
    }
}

// MARK: - Phase 1: Coarse placement

struct MapView: View {
    @StateObject var viewModel = MapViewModel()
    @State var opacity: Double = 0.5

    private let scaling = 0.9

    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scaling)
                    .allowsHitTesting(false)
            }
            CustomMapView(
                overlays: $viewModel.photos,
                visibleMapRect: $viewModel.visibleMapRect,
                moveTo: $viewModel.moveTo
            )
            .opacity(viewModel.image == nil ? 1 : 1 - opacity)

            if viewModel.image != nil {
                VStack {
                    TextField("Name", text: $viewModel.currentImageName)
                        .multilineTextAlignment(.center)
                        .background(Color.white)
                        .padding(20)
                    Spacer()
                }
                .padding(.bottom, 70)
            }

            VStack {
                Spacer()
                HStack(spacing: 20) {
                    if let image = viewModel.image {
                        Slider(value: $opacity, in: 0...1)
                        Button(action: {
                            viewModel.onCoarseDone(
                                imageToPlace: image,
                                corners: coarseCorners(for: image)
                            )
                        }, label: {
                            Text("Done").bold()
                        })
                        .padding(8)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .clipShape(Capsule())
                    } else {
                        Spacer()
                        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                            SFSymbolsButton(image: "photo.on.rectangle.angled") {
                                viewModel.pickingFrom = .photoLibrary
                            }
                        }
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            SFSymbolsButton(image: "camera") {
                                viewModel.pickingFrom = .camera
                            }
                        }
                    }
                }.padding(20)
            }
        }
        .navigationBarItems(trailing: NavigationLink(destination: CurrentPicturesView(viewModel: viewModel)) {
            Text("List images")
        }.disabled(viewModel.image != nil))
        .sheet(item: $viewModel.pickingFrom) { item in
            ImageCropPicker(sourceType: item, originalImage: $viewModel.originalImage, croppedImage: $viewModel.image)
        }
        // Phase 2: fine-tune sheet, triggered after Phase 1 Done or from list Edit
        .sheet(isPresented: Binding(
            get: { viewModel.fineTuningPhoto != nil },
            set: { if !$0 { viewModel.cancelFineTune() } }
        )) {
            FineTuneView(viewModel: viewModel)
        }
        .onAppear {
            let locationManager = CLLocationManager()
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        .onAppear {
            UserDefaults.standard.set(true, forKey: "seenIntro")
        }
    }

    /// Derive 4 initial axis-aligned MKMapPoints from the visible map rect,
    /// aspect-ratio corrected and scaled to 0.9 — same logic as the old onDone.
    private func coarseCorners(for image: UIImage) -> [MKMapPoint] {
        let imageAspectRatio = Double(image.size.height / image.size.width)
        let mapAspectRatio = Double(viewModel.visibleMapRect.size.height / viewModel.visibleMapRect.size.width)

        var mapRect = viewModel.visibleMapRect
        if mapAspectRatio > imageAspectRatio {
            let heightChange = mapRect.size.height - mapRect.size.width * imageAspectRatio
            mapRect.size.height = mapRect.size.width * imageAspectRatio
            mapRect.origin.y += heightChange / 2
        } else {
            let widthChange = mapRect.size.width - mapRect.size.height / imageAspectRatio
            mapRect.size.width = mapRect.size.height / imageAspectRatio
            mapRect.origin.x += widthChange / 2
        }

        return mapRect.adjusted(scaling: scaling).corners
    }
}

// MARK: - Phase 2: Fine-tune with corner handles

struct FineTuneView: View {
    @ObservedObject var viewModel: MapViewModel

    @State private var lastRotation: Angle = .zero
    @State private var lastScale: CGFloat = 1.0
    @State private var opacity: Double = 0.7

    var body: some View {
        ZStack(alignment: .top) {
            CustomMapView(
                overlays: $viewModel.photos,
                visibleMapRect: $viewModel.visibleMapRect,
                moveTo: $viewModel.moveTo,
                fineTuningOverlay: viewModel.fineTuningPhoto,
                overlayOpacity: opacity,
                onCornerMoved: { index, coord in
                    viewModel.updateCorner(index: index, to: coord)
                }
            )
            .simultaneousGesture(rotateScaleGesture)
            .ignoresSafeArea()

            VStack {
                // Top bar
                HStack {
                    Button("Cancel") {
                        viewModel.cancelFineTune()
                    }
                    .padding()
                    Spacer()
                    Text(viewModel.currentImageName.isEmpty ? "Fine-tune" : viewModel.currentImageName)
                        .bold()
                    Spacer()
                    Button("Save") {
                        viewModel.commitFineTune()
                    }
                    .bold()
                    .padding()
                }
                .background(.ultraThinMaterial)

                Spacer()

                // Opacity slider with discrete steps
                HStack {
                    Image(systemName: "circle.lefthalf.filled")
                        .foregroundColor(.secondary)
                    Slider(value: $opacity, in: 0.1...1, step: 0.1)
                        .padding(.horizontal, 8)
                    Image(systemName: "circle.fill")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(.ultraThinMaterial)
            }
        }
    }

    /// Two-finger pinch + rotate that adjusts all 4 corners around their centroid.
    private var rotateScaleGesture: some Gesture {
        SimultaneousGesture(RotationGesture(), MagnificationGesture())
            .onChanged { value in
                let currentRotation = value.first ?? .zero
                let currentScale = value.second ?? 1.0

                let deltaAngle = currentRotation.radians - lastRotation.radians
                let deltaScale = Double(currentScale / lastScale)

                if abs(deltaAngle) > 0.001 || abs(deltaScale - 1.0) > 0.001 {
                    viewModel.rotateScale(angle: deltaAngle, scale: deltaScale)
                }

                lastRotation = currentRotation
                lastScale = currentScale
            }
            .onEnded { _ in
                lastRotation = .zero
                lastScale = 1.0
            }
    }
}

extension UIImagePickerController.SourceType: Identifiable {
    public var id: Int {
        rawValue
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .previewDevice("iPhone X")
    }
}
