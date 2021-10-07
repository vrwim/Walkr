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
                        .frame(width: 80, height: 80)
                        .padding(4)
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Longitude:").bold()
                            Text("\(photo.coordinate.longitude)")
                        }
                        HStack {
                            Text("Latitude:").bold()
                            Text("\(photo.coordinate.latitude)")
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
