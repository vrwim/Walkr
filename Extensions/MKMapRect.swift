//
//  MKMapRect.swift
//  Walkr (iOS)
//
//  Created by Wim Van Renterghem on 04/02/2023.
//

import MapKit

extension MKMapRect: Codable {
    private enum CodingKeys: String, CodingKey {
        case originLatitude
        case originLongitude
        case sizeWidth
        case sizeHeight
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(origin.coordinate.latitude, forKey: .originLatitude)
        try container.encode(origin.coordinate.longitude, forKey: .originLongitude)
        try container.encode(size.width, forKey: .sizeWidth)
        try container.encode(size.height, forKey: .sizeHeight)
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let originLatitude = try values.decode(Double.self, forKey: .originLatitude)
        let originLongitude = try values.decode(Double.self, forKey: .originLongitude)
        let sizeWidth = try values.decode(Double.self, forKey: .sizeWidth)
        let sizeHeight = try values.decode(Double.self, forKey: .sizeHeight)
        
        let origin = MKMapPoint(CLLocationCoordinate2D(latitude: originLatitude, longitude: originLongitude))
        let size = MKMapSize(width: sizeWidth, height: sizeHeight)
        
        self.init(origin: origin, size: size)
    }
    
    var sizeInMeters: (width: CLLocationDistance, height: CLLocationDistance) {
        let eastMapPoint = MKMapPoint(x: self.minX, y: self.midY)
        let westMapPoint = MKMapPoint(x: self.maxX, y: self.midY)
        let widthInMeters = eastMapPoint.distance(to: westMapPoint)
        let heightInMeters = widthInMeters * height / width
        return (widthInMeters, heightInMeters)
    }
    
    var sizeString: String {
        let (width, height) = sizeInMeters
        return "\(formatSize(size: width)) by \(formatSize(size: height))"
    }
    
    // Format sizeInMeters, use meters when < 1000, use kilometers when > 1000
    private func formatSize(size: CLLocationDistance) -> String {
        if size < 1000 {
            return "\(Int(size))m"
        } else {
            return String(format: "%.2f", size / 1000) + "km"
        }
    }
}
