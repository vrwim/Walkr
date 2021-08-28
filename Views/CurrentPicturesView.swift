//
//  CurrentPicturesView.swift
//  Walkr (iOS)
//
//  Created by Wim Van Renterghem on 26/03/2021.
//

import SwiftUI

struct CurrentPicturesView: View {
    @Binding var photos: [ImageOverlay]
    var body: some View {
        Form {
            ForEach(photos, id: \.self) { photo in
                HStack {
                    Image(uiImage: photo.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .padding(4)
                    VStack {
                        HStack {
                            Text("Longitude:").bold()
                            Text("\(photo.coordinate.longitude)")
                        }
                        HStack {
                            Text("Latitude:").bold()
                            Text("\(photo.coordinate.latitude)")
                        }
                        HStack {
                            Text("Rotation:").bold()
                            Text("\(photo.rotation)")
                        }
                    }
                    .font(.footnote)
                }
            }
        }
    }
}

struct CurrentPicturesView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentPicturesView(photos: .constant([]))
    }
}