//
//  CurrentPicturesView.swift
//  Walkr (iOS)
//
//  Created by Wim Van Renterghem on 26/03/2021.
//

import SwiftUI

struct CurrentPicturesView: View {
    @ObservedObject var viewModel: MapViewModel
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            ForEach(viewModel.photos, id: \.self) { photo in
                HStack {
                    Button(action: {
                        viewModel.toggle(photo)
                    }) {
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(photo.enabled ? .green : .gray)
                    }
                    .buttonStyle(.borderless)
                    Image(uiImage: photo.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .padding(4)
                    VStack(alignment: .leading) {
                        Text(photo.name).bold()
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
                    
                    Spacer()
                    
                    Button {
                        viewModel.startEditing(photo)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "pencil")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.borderless)
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
