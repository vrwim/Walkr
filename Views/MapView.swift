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
    
    var body: some View {
        ZStack {
            if let image = viewModel.currentImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            CustomMapView(overlays: $viewModel.photos, visibleMapRect: $viewModel.visibleMapRect, moveTo: $viewModel.moveTo)
                .opacity(viewModel.currentImage == nil ? 1 : 0.5)
            if viewModel.currentImage != nil {
                VStack {
                    TextField("Name", text: $viewModel.currentImageName)
                        .multilineTextAlignment(.center)
                        .background(Color.white)
                        .padding(20)
                    
                    Spacer()
                }
            }
            // Button(s)
            VStack {
                Spacer()
                HStack(spacing: 20) {
                    Spacer()
                    if let image = viewModel.currentImage {
                        // Aligning image, show done button
                        Button(action: {
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
                            
                            viewModel.onDone(mapRect)
                            
                        }, label: {
                            Text("Done").bold()
                        })
                        .padding(8)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .clipShape(Capsule())
                    } else {
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
        })
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
