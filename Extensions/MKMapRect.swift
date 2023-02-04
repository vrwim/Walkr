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
}
