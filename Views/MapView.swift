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

struct MapView: View {
    @StateObject var viewModel = MapViewModel()
    @State var opacity: Double = 0.5
    
    private var scaling = 0.9
    
    var body: some View {
        ZStack {
            if let image = viewModel.currentImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scaling)
            }
            CustomMapView(overlays: $viewModel.photos, visibleMapRect: $viewModel.visibleMapRect, moveTo: $viewModel.moveTo)
                .opacity(viewModel.currentImage == nil ? 1 : 1 - opacity)
            if viewModel.currentImage != nil {
                VStack {
                    TextField("Name", text: $viewModel.currentImageName)
                        .multilineTextAlignment(.center)
                        .background(Color.white)
                        .padding(20)
                    Spacer()
                    HStack {
                    }
                    .padding([.leading, .trailing], 20)
                }
                .padding(.bottom, 70)
            }
            // Button(s)
            VStack {
                Spacer()
                HStack(spacing: 20) {
                    if let image = viewModel.currentImage {
                        Slider(value: $opacity, in: 0...1)
                        // Aligning image, show done button
                        Button(action: {
                            let imageAspectRatio = Double(image.size.height / image.size.width)
                            let mapAspectRatio = Double(viewModel.visibleMapRect.size.height / viewModel.visibleMapRect.size.width)
                            
                            var mapRect = viewModel.visibleMapRect
                            if mapAspectRatio > imageAspectRatio {
                                // Image is wider than the map, adjust height to match image aspect ratio
                                let heightChange = mapRect.size.height - mapRect.size.width * imageAspectRatio
                                mapRect.size.height = mapRect.size.width * imageAspectRatio
                                mapRect.origin.y += heightChange / 2
                            } else {
                                // Image is taller than the map, adjust width to match image aspect ratio
                                let widthChange = mapRect.size.width - mapRect.size.height / imageAspectRatio
                                mapRect.size.width = mapRect.size.height / imageAspectRatio
                                mapRect.origin.x += widthChange / 2
                            }
                            
                            viewModel.onDone(mapRect.adjusted(scaling: scaling))
                            
                        }, label: {
                            Text("Done").bold()
                        })
                        .padding(8)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .clipShape(Capsule())
                    } else {
                        Spacer()
                        // Not aligning image, show buttons to pick a new image
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
        }.disabled(viewModel.currentImage != nil))
        .sheet(item: $viewModel.pickingFrom) { item in
            ImageCropPicker(sourceType: item, originalImage: $viewModel.originalImage, croppedImage: $viewModel.image)
        }
        .onAppear {
            let locationManager = CLLocationManager()
            locationManager.requestWhenInUseAuthorization() // Ask for location permission if needed
            locationManager.startUpdatingLocation() // Start updating user location
        }
        .onAppear {
            UserDefaults.standard.set(true, forKey: "seenIntro")
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
