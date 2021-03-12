//
//  ContentView.swift
//  Shared
//
//  Created by Wim Van Renterghem on 12/03/2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("How this app works")
                .font(.title)
            Text("This app can overlay a picture of a route on the map, allowing you to see your location in the route in real time")
            Button(action: {
                // TODO: navigationlink to the camera/picture view
            }, label: {
                Text("Click here to start")
            }).padding(20)
        }
        .padding(20)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
