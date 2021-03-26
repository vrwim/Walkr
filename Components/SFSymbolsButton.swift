//
//  SFSymbolsButton.swift
//  Walkr (iOS)
//
//  Created by Wim Van Renterghem on 16/03/2021.
//

import SwiftUI

struct SFSymbolsButton: View {
    var image: String
    var action: () -> ()
    
    var body: some View {
        Button(action: action) {
            Image(systemName: image)
                .imageScale(.large)
                .foregroundColor(.blue)
        }
    }
}

struct SFSymbolsButton_Previews: PreviewProvider {
    static var previews: some View {
        SFSymbolsButton(image: "photo.on.rectangle.angled", action: { })
    }
}
