//
//  MapViewModel.swift
//  Walkr (iOS)
//
//  Created by Wim Van Renterghem on 04/02/2023.
//

import UIKit

class MapViewModel: ObservableObject {
    @Published var photos: [ImageOverlay]
    
    init() {
        guard let fromUserDefaults = UserDefaults.standard.data(forKey: "imageOverlays") else {
            print("No photos")
            photos = []
            return
        }
        photos = try! JSONDecoder().decode([ImageOverlay].self, from: fromUserDefaults)
    }
    
    func addImageOverlay(_ imageOverlay: ImageOverlay) {
        photos.append(imageOverlay)
        saveImages()
    }
    
    func removeImage(at index: Int) {
        photos.remove(at: index)
        saveImages()
    }
    
    func saveImages() {
        UserDefaults.standard.set(try! JSONEncoder().encode(photos), forKey: "imageOverlays")
        UserDefaults.standard.synchronize()
    }
}
