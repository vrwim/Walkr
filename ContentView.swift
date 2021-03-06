//
//  ContentView.swift
//  Shared
//
//  Created by Wim Van Renterghem on 12/03/2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("How this app works")
                    .font(.title)
                Text("This app can overlay a picture of a route on the map, allowing you to see your location in the route in real time")
                NavigationLink(destination: MapView()) {
                    Text("Go!")
                        .font(.title)
                }
                .padding(20)
            }
            .padding(20)
        }
    }
}

enum SheetType: String, Identifiable {
    var id: String { rawValue }
    
    case camera
    case photoLibrary
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
