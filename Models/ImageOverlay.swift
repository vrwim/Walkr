//
//  ImageOverlay.swift
//  Walkr (iOS)
//
//  Created by Wim Van Renterghem on 22/03/2021.
//

import MapKit

class ImageOverlay: NSObject, MKOverlay, Codable {
    var id = UUID()
    let image: UIImage
    var topLeft: MKMapPoint
    var topRight: MKMapPoint
    var bottomLeft: MKMapPoint
    var bottomRight: MKMapPoint
    var enabled: Bool
    var name: String

    // MKOverlay conformance: bounding box computed from the 4 corners
    var boundingMapRect: MKMapRect {
        let xs = [topLeft.x, topRight.x, bottomLeft.x, bottomRight.x]
        let ys = [topLeft.y, topRight.y, bottomLeft.y, bottomRight.y]
        let minX = xs.min()!
        let minY = ys.min()!
        let maxX = xs.max()!
        let maxY = ys.max()!
        return MKMapRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    var coordinate: CLLocationCoordinate2D {
        boundingMapRect.origin.coordinate
    }

    /// Convenience: corners in TL, TR, BL, BR order.
    var cornersArray: [MKMapPoint] { [topLeft, topRight, bottomLeft, bottomRight] }

    init(image: UIImage, topLeft: MKMapPoint, topRight: MKMapPoint, bottomLeft: MKMapPoint, bottomRight: MKMapPoint, name: String) {
        self.image = image.fixedOrientation() ?? image
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
        self.enabled = true
        self.name = name
    }

    /// Convenience initialiser that derives 4 axis-aligned corners from a rect (used during Phase 1 → Phase 2 handoff).
    convenience init(image: UIImage, rect: MKMapRect, name: String) {
        let tl = MKMapPoint(x: rect.minX, y: rect.minY)
        let tr = MKMapPoint(x: rect.maxX, y: rect.minY)
        let bl = MKMapPoint(x: rect.minX, y: rect.maxY)
        let br = MKMapPoint(x: rect.maxX, y: rect.maxY)
        self.init(image: image, topLeft: tl, topRight: tr, bottomLeft: bl, bottomRight: br, name: name)
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(UUID.self, forKey: .id)
        self.image = UIImage.loadImage(key: self.id.uuidString)!
        self.enabled = (try? values.decode(Bool.self, forKey: .enabled)) ?? true
        self.name = (try? values.decode(String.self, forKey: .name)) ?? ""

        // New format: 4 explicit corners
        if let tl = try? values.decode(MKMapPoint.self, forKey: .topLeft) {
            self.topLeft = tl
            self.topRight = try values.decode(MKMapPoint.self, forKey: .topRight)
            self.bottomLeft = try values.decode(MKMapPoint.self, forKey: .bottomLeft)
            self.bottomRight = try values.decode(MKMapPoint.self, forKey: .bottomRight)
        } else {
            // Legacy format: decode MKMapRect and derive axis-aligned corners
            let rect = try values.decode(MKMapRect.self, forKey: .boundingMapRect)
            self.topLeft = MKMapPoint(x: rect.minX, y: rect.minY)
            self.topRight = MKMapPoint(x: rect.maxX, y: rect.minY)
            self.bottomLeft = MKMapPoint(x: rect.minX, y: rect.maxY)
            self.bottomRight = MKMapPoint(x: rect.maxX, y: rect.maxY)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        image.saveImage(key: id.uuidString)
        try container.encode(topLeft, forKey: .topLeft)
        try container.encode(topRight, forKey: .topRight)
        try container.encode(bottomLeft, forKey: .bottomLeft)
        try container.encode(bottomRight, forKey: .bottomRight)
        try container.encode(enabled, forKey: .enabled)
        try container.encode(name, forKey: .name)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case topLeft, topRight, bottomLeft, bottomRight
        case boundingMapRect  // legacy key, decode only
        case enabled
        case name
    }
}
