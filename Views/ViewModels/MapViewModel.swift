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
    /// The image currently being placed (Phase 1 coarse alignment)
    @Published var image: UIImage?
    @Published var pickingFrom: UIImagePickerController.SourceType?
    @Published var isPickerVisible = false
    @Published var visibleMapRect = MKMapRect(origin: MKMapPoint(CLLocationCoordinate2D(latitude: 51, longitude: 3)), size: MKMapSize(width: 200_000, height: 200_000))
    @Published var photos: [ImageOverlay]
    /// The overlay currently being fine-tuned (Phase 2)
    @Published var fineTuningPhoto: ImageOverlay?
    /// True when the fine-tuned overlay was just created in Phase 1 (cancel should remove it)
    @Published var fineTuneIsNewlyAdded = false
    @Published var moveTo: MKMapRect?
    @Published var currentImageName = ""

    private var fineTuningIndex: Int?
    private let scaling = 0.9

    init() {
        guard let fromUserDefaults = UserDefaults.standard.data(forKey: "imageOverlays") else {
            print("No photos")
            photos = []
            return
        }
        photos = try! JSONDecoder().decode([ImageOverlay].self, from: fromUserDefaults)
    }

    // MARK: - Phase 1: Coarse alignment → Phase 2

    /// Called when the user taps "Done" in Phase 1. Converts the visible map rect into 4
    /// axis-aligned corners, creates the overlay, saves it, and enters Phase 2 fine-tune.
    func onCoarseDone(imageToPlace: UIImage, corners: [MKMapPoint]) {
        precondition(corners.count == 4)
        let overlay = ImageOverlay(
            image: imageToPlace,
            topLeft: corners[0], topRight: corners[1],
            bottomLeft: corners[2], bottomRight: corners[3],
            name: currentImageName
        )
        self.image = nil
        photos.append(overlay)
        fineTuningIndex = photos.count - 1
        fineTuningPhoto = overlay
        fineTuneIsNewlyAdded = true
        moveTo = overlay.boundingMapRect
        saveImages()
    }

    // MARK: - Phase 2: Fine-tune

    /// Update a single corner from a drag event. Index: 0=TL, 1=TR, 2=BL, 3=BR.
    func updateCorner(index: Int, to coordinate: CLLocationCoordinate2D) {
        guard let photo = fineTuningPhoto,
              let idx = fineTuningIndex else { return }

        let point = MKMapPoint(coordinate)
        switch index {
        case 0: photo.topLeft = point
        case 1: photo.topRight = point
        case 2: photo.bottomLeft = point
        case 3: photo.bottomRight = point
        default: break
        }
        // Reassign to trigger @Published update and map re-render
        photos[idx] = photo
        fineTuningPhoto = photo
    }

    /// Rotate and scale all 4 corners around their centroid.
    func rotateScale(angle: Double, scale: Double) {
        guard let photo = fineTuningPhoto,
              let idx = fineTuningIndex else { return }

        let corners = photo.cornersArray
        let centroidX = corners.map(\.x).reduce(0, +) / 4
        let centroidY = corners.map(\.y).reduce(0, +) / 4

        func transform(_ p: MKMapPoint) -> MKMapPoint {
            let dx = p.x - centroidX
            let dy = p.y - centroidY
            let rotatedX = dx * cos(angle) - dy * sin(angle)
            let rotatedY = dx * sin(angle) + dy * cos(angle)
            return MKMapPoint(x: centroidX + rotatedX * scale, y: centroidY + rotatedY * scale)
        }

        photo.topLeft = transform(photo.topLeft)
        photo.topRight = transform(photo.topRight)
        photo.bottomLeft = transform(photo.bottomLeft)
        photo.bottomRight = transform(photo.bottomRight)

        photos[idx] = photo
        fineTuningPhoto = photo
    }

    /// Commit fine-tune changes and exit Phase 2.
    func commitFineTune() {
        guard let idx = fineTuningIndex, let photo = fineTuningPhoto else { return }
        photo.name = currentImageName
        photos[idx] = photo
        fineTuningPhoto = nil
        fineTuningIndex = nil
        fineTuneIsNewlyAdded = false
        currentImageName = ""
        saveImages()
    }

    /// Discard fine-tune edits. Removes the overlay if it was just added in Phase 1.
    func cancelFineTune() {
        if fineTuneIsNewlyAdded, let idx = fineTuningIndex {
            photos.remove(at: idx)
            saveImages()
        }
        fineTuningPhoto = nil
        fineTuningIndex = nil
        fineTuneIsNewlyAdded = false
        currentImageName = ""
    }

    // MARK: - List management

    func startEditing(_ photo: ImageOverlay) {
        guard let index = photos.firstIndex(of: photo) else {
            print("Not editing a current photo!")
            return
        }
        self.fineTuningIndex = index
        self.fineTuningPhoto = photo
        self.fineTuneIsNewlyAdded = false
        self.currentImageName = photo.name
        moveTo = photo.boundingMapRect.adjusted(scaling: 1 / scaling)
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
        if fineTuningPhoto === photos[index] {
            fineTuningPhoto = nil
            fineTuningIndex = nil
        }
        photos.remove(at: index)
        saveImages()
    }

    func move(from: IndexSet, to: Int) {
        photos.move(fromOffsets: from, toOffset: to)
        saveImages()
    }

    // MARK: - Persistence

    private func saveImages() {
        UserDefaults.standard.set(try! JSONEncoder().encode(photos), forKey: "imageOverlays")
        UserDefaults.standard.synchronize()
    }
}
