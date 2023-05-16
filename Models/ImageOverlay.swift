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
    var boundingMapRect: MKMapRect
    var enabled: Bool
    var name: String
    
    var coordinate: CLLocationCoordinate2D {
        boundingMapRect.origin.coordinate
    }
    
    init(image: UIImage, rect: MKMapRect, name: String) {
        self.image = image.fixedOrientation() ?? image
        self.boundingMapRect = rect
        self.enabled = true
        self.name = name
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(UUID.self, forKey: .id)
        self.image = UIImage.loadImage(key: self.id.uuidString)!
        self.boundingMapRect = try values.decode(MKMapRect.self, forKey: .boundingMapRect)
        self.enabled = (try? values.decode(Bool.self, forKey: .enabled)) ?? true
        self.name = (try? values.decode(String.self, forKey: .name)) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        image.saveImage(key: id.uuidString)
        try container.encode(boundingMapRect, forKey: .boundingMapRect)
        try container.encode(enabled, forKey: .enabled)
        try container.encode(name, forKey: .name)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case boundingMapRect
        case enabled
        case name
    }
}
