//
//  CornerAnnotation.swift
//  Walkr (iOS)
//

import MapKit

/// An MKAnnotation representing one draggable corner of an ImageOverlay.
class CornerAnnotation: NSObject, MKAnnotation {
    /// 0 = topLeft, 1 = topRight, 2 = bottomLeft, 3 = bottomRight
    let cornerIndex: Int
    weak var overlay: ImageOverlay?

    @objc dynamic var coordinate: CLLocationCoordinate2D

    init(cornerIndex: Int, overlay: ImageOverlay) {
        self.cornerIndex = cornerIndex
        self.overlay = overlay
        self.coordinate = overlay.cornersArray[cornerIndex].coordinate
    }

    func updateCoordinate(_ coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
