//
//  MapView.swift
//  Walkr
//
//  Created by Wim Van Renterghem on 12/03/2021.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State var image: UIImage?
    @State var pickingFrom: UIImagePickerController.SourceType?
    @State var photos: [ImageOverlay] = []
    @State var visibleMapRect = MKMapRect(origin: MKMapPoint(CLLocationCoordinate2D(latitude: 51, longitude: 3)), size: MKMapSize(width: 200_000, height: 200_000))
    @State var cameraHeading: CLLocationDirection = 0
    
    var body: some View {
        Group {
            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                CustomMapView(overlays: $photos, visibleMapRect: $visibleMapRect, cameraHeading: $cameraHeading)
                .ignoresSafeArea()
                .opacity(image == nil ? 1 : 0.5)
                VStack {
                    Spacer()
                    HStack(spacing: 20) {
                        Spacer()
                        if image == nil {
                            // Not aligning image, show buttons to pick a new image
                            SFSymbolsButton(image: "photo.on.rectangle.angled") {
                                pickingFrom = .photoLibrary
                            }
                            SFSymbolsButton(image: "camera") {
                                pickingFrom = .camera
                            }
                        } else {
                            // Aligning image, show done button
                            Button(action: {
                                guard let image = image else {
                                    fatalError("This button shouldn't be here!")
                                }
                                
                                let imageAspectRatio = Double(image.size.height / image.size.width)
                                
                                var mapRect = visibleMapRect
                                let heightChange = mapRect.size.width * imageAspectRatio - mapRect.size.height
                                mapRect.size.height = mapRect.size.width * imageAspectRatio
                                mapRect.origin.y -= heightChange / 2
                                
                                photos.append(ImageOverlay(image: image, rect: mapRect, rotation: cameraHeading))
                                
                                self.image = nil
                            }, label: {
                                Text("Done")
                            })
                        }
                    }.padding(20)
                }
            }
        }
        .sheet(item: $pickingFrom) { item in
            ImagePicker(sourceType: item, selectedImage: $image)
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
        MapView(image: UIImage(systemName: "circle")!, photos: [])
            .previewDevice("iPhone X")
    }
}
