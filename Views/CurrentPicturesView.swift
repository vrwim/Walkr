//
//  CurrentPicturesView.swift
//  Walkr (iOS)
//
//  Created by Wim Van Renterghem on 26/03/2021.
//

import SwiftUI

struct CurrentPicturesView: View {
    var viewModel: MapViewModel
    var body: some View {
        Form {
            ForEach(viewModel.photos, id: \.self) { photo in
                HStack {
                    Image(uiImage: photo.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .padding(4)
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Longitude:").bold()
                            Text(photo.coordinate.longitudeString)
                        }
                        HStack {
                            Text("Latitude:").bold()
                            Text(photo.coordinate.latitudeString)
                        }
                        HStack {
                            Text("Size:").bold()
                            Text(photo.boundingMapRect.sizeString)
                        }
                    }
                    .font(.footnote)
                }
            }
            .onDelete { index in
                viewModel.removeImage(at: Int(index.first!))
            }
        }
    }
}

struct CurrentPicturesView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentPicturesView(viewModel: MapViewModel())
    }
}
