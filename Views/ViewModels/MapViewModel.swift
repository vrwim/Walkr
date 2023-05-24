//
//  MapViewModel.swift
//  Walkr (iOS)
//
//  Created by Wim Van Renterghem on 04/02/2023.
//

import UIKit
import MapKit

class MapViewModel: ObservableObject {
    @Published var originalImage: UIImage?
    /// The image currently aligning
    @Published var image: UIImage?
    @Published var pickingFrom: UIImagePickerController.SourceType?
    @Published var isPickerVisible = false
    @Published var visibleMapRect = MKMapRect(origin: MKMapPoint(CLLocationCoordinate2D(latitude: 51, longitude: 3)), size: MKMapSize(width: 200_000, height: 200_000))
    @Published var photos: [ImageOverlay]
    @Published var editingPhoto: ImageOverlay?
    @Published var moveTo: MKMapRect?
    @Published var currentImageName = ""
    
    private var editingIndex: Int?
    
    init() {
        guard let fromUserDefaults = UserDefaults.standard.data(forKey: "imageOverlays") else {
            print("No photos")
            photos = []
            return
        }
        photos = try! JSONDecoder().decode([ImageOverlay].self, from: fromUserDefaults)
    }
    
    var currentImage: UIImage? {
        image ?? editingPhoto?.image
    }
    
    func onDone(_ mapRect: MKMapRect) {
        if image != nil {
            addImageOverlay(mapRect)
        } else if editingPhoto != nil {
            editImageOverlay(mapRect)
        }
    }
    
    func startEditing(_ photo: ImageOverlay) {
        guard let index = photos.firstIndex(of: photo) else {
            print("Not editing a current photo!")
            self.editingPhoto = nil
            return
        }
        self.editingIndex = index
        self.editingPhoto = photo
        self.currentImageName = photos[index].name
        moveTo = photo.boundingMapRect
        photos.remove(at: photos.firstIndex(of: photo)!)
    }
    
    func toggle(_ photo: ImageOverlay) {
        guard let index = photos.firstIndex(of: photo) else {
            print("Not toggling a current photo!")
            return
        }
        
        photo.enabled.toggle()
        photos[index] = photo
        
        saveImages()
    }
    
    func removeImage(at index: Int) {
        // Remove editing photo in case it was the current one
        self.editingPhoto = nil
        
        photos.remove(at: index)
        saveImages()
    }
    
    func move(from: IndexSet, to: Int) {
        photos.move(fromOffsets: from, toOffset: to)
        saveImages()
    }
    
    private func saveImages() {
        UserDefaults.standard.set(try! JSONEncoder().encode(photos), forKey: "imageOverlays")
        UserDefaults.standard.synchronize()
    }
    
    private func addImageOverlay(_ mapRect: MKMapRect) {
        guard let image else {
            return
        }
        photos.append(ImageOverlay(image: image, rect: mapRect, name: currentImageName))
        
        self.image = nil
        saveImages()
    }
    
    private func editImageOverlay(_ mapRect: MKMapRect) {
        guard let editingPhoto, let editingIndex else {
            fatalError("Not editing a photo??")
        }
                
        // Need to add a new object to force the map to reload
        photos.insert(ImageOverlay(image: editingPhoto.image, rect: mapRect, name: currentImageName), at: editingIndex)
        
        self.editingPhoto = nil
        saveImages()
    }
}
