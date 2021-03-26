//
//  ImageOverlay.swift
//  Walkr (iOS)
//
//  Created by Wim Van Renterghem on 22/03/2021.
//

import MapKit

class ImageOverlay: NSObject, MKOverlay {
    let image: UIImage
    let boundingMapRect: MKMapRect
    let coordinate: CLLocationCoordinate2D
    let rotation: CLLocationDirection
    
    init(image: UIImage, rect: MKMapRect, rotation: CLLocationDirection) {
        self.image = UIImage.fixedOrientation(for: image) ?? image
        self.boundingMapRect = rect
        self.coordinate = CLLocationCoordinate2D(latitude: rect.midX, longitude: rect.midY)
        self.rotation = rotation
    }
}
