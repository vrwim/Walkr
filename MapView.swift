//
//  MapView.swift
//  Walkr
//
//  Created by Wim Van Renterghem on 12/03/2021.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    @State var image: UIImage?
    @State var pickingFrom: UIImagePickerController.SourceType?
    
    var body: some View {
        Group {
            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Map(coordinateRegion: $region)
                        .ignoresSafeArea()
                        .opacity(0.5)
                } else {
                    Map(coordinateRegion: $region)
                        .ignoresSafeArea()
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
                                // TODO: paste image on map
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
        MapView(image: UIImage(systemName: "circle")!)
            .previewDevice("iPhone X")
    }
}
