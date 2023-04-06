//
//  MapView.swift
//  Walkr
//
//  Created by Wim Van Renterghem on 12/03/2021.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State var originalImage: UIImage?
    /// The image currently aligning
    @State var image: UIImage?
    @State var pickingFrom: UIImagePickerController.SourceType?
    @State var isPickerVisible = false
    @StateObject var viewModel = MapViewModel()
    @State var visibleMapRect = MKMapRect(origin: MKMapPoint(CLLocationCoordinate2D(latitude: 51, longitude: 3)), size: MKMapSize(width: 200_000, height: 200_000))
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            CustomMapView(overlays: $viewModel.photos, visibleMapRect: $visibleMapRect)
                .opacity(image == nil ? 1 : 0.5)
            VStack {
                Spacer()
                HStack(spacing: 20) {
                    Spacer()
                    if image == nil {
                        // Not aligning image, show buttons to pick a new image
                        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                            SFSymbolsButton(image: "photo.on.rectangle.angled") {
                                pickingFrom = .photoLibrary
                            }
                        }
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            SFSymbolsButton(image: "camera") {
                                pickingFrom = .camera
                            }
                        }
                    } else {
                        // Aligning image, show done button
                        Button(action: {
                            guard let image = image else {
                                fatalError("This button shouldn't be here!")
                            }
                            
                            let imageAspectRatio = Double(image.size.height / image.size.width)
                            let mapAspectRatio = Double(visibleMapRect.size.height / visibleMapRect.size.width)
                            
                            var mapRect = visibleMapRect
                            if mapAspectRatio > imageAspectRatio {
                                let heightChange = mapRect.size.height - mapRect.size.width * imageAspectRatio
                                mapRect.size.height = mapRect.size.width * imageAspectRatio
                                mapRect.origin.y += heightChange / 2
                            } else {
                                let widthChange = mapRect.size.width - mapRect.size.height / imageAspectRatio
                                mapRect.size.width = mapRect.size.height / imageAspectRatio
                                mapRect.origin.x += widthChange / 2
                            }
                            
                            viewModel.addImageOverlay(ImageOverlay(image: image, rect: mapRect))
                            
                            self.image = nil
                        }, label: {
                            Text("Done")
                        })
                    }
                }.padding(20)
            }
        }
        .navigationBarItems(trailing: NavigationLink(destination: CurrentPicturesView(viewModel: viewModel)) {
            Text("List images")
        })
        .sheet(item: $pickingFrom) { item in
            ImageCropPicker(sourceType: item, originalImage: $originalImage, croppedImage: $image)
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
