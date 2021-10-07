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
    
    @State var sizeWhenAdded: MKMapRect?
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            GeometryReader { geometry in
                CustomMapView(overlays: $photos, visibleMapRect: $visibleMapRect, cameraHeading: $cameraHeading)
                    .opacity(image == nil ? 1 : 0.5)
                    .andPrint(geometry.size)
            }
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
                            let mapAspectRatio = Double(visibleMapRect.size.height / visibleMapRect.size.width)
                            
                            var mapRect = visibleMapRect
                            
                            if mapAspectRatio > imageAspectRatio {
                                // Aspect ratio of map is bigger than aspect ratio of image (map is higher than the image), take away height from the rectangle
                                let heightChange = mapRect.size.height - mapRect.size.width * imageAspectRatio
                                mapRect.size.height = mapRect.size.width * imageAspectRatio
                                mapRect.origin.y += heightChange / 2
                            } else {
                                // Aspect ratio of map is smaller than aspect ratio of image (map is higher than the image), take away width from the rectangle
                                let widthChange = mapRect.size.width - mapRect.size.height / imageAspectRatio
                                mapRect.size.width = mapRect.size.height / imageAspectRatio
                                mapRect.origin.x += widthChange / 2
                            }
                            
                            photos.append(ImageOverlay(image: image, boundingMapRect: mapRect, rotation: cameraHeading))
                            
                            print("Rotated@\(Int(cameraHeading)), Size when added: \(visibleMapRect.size)")
                            sizeWhenAdded = visibleMapRect
                            
                            self.image = nil
                        }, label: {
                            Text("Done")
                        })
                    }
                }.padding(20)
            }
        }
        .navigationBarItems(trailing: NavigationLink(destination: CurrentPicturesView(photos: $photos)) {
            Text("List images")
        })
        .sheet(item: $pickingFrom) { item in
            ImagePicker(sourceType: item, selectedImage: $image)
        }
        .onChange(of: visibleMapRect) { value in
            guard let sizeWhenAdded = sizeWhenAdded else {
                print("Rotated@\(Int(cameraHeading))")
                return
            }
            print("Rotated@\(Int(cameraHeading)), Size compared to add: \(sizeWhenAdded.width / visibleMapRect.width)")
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
        MapView(image: nil, photos: [])
            .previewDevice("iPhone X")
    }
}
