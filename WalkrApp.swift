//
//  WalkrApp.swift
//  Shared
//
//  Created by Wim Van Renterghem on 12/03/2021.
//

import SwiftUI

@main
struct WalkrApp: App {
    let seenIntro: Bool
    
    init() {
        seenIntro = UserDefaults.standard.bool(forKey: "seenIntro")
    }
    
    var body: some Scene {
        WindowGroup {
            
            NavigationView {
                if seenIntro {
                    MapView()
                } else {
                    IntroView()
                }
            }
        }
    }
}
