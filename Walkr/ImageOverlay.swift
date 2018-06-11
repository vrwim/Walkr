//
//  ImageOverlay.swift
//  Walkr
//
//  Created by Wim Van Renterghem on 12/03/2018.
//  Copyright © 2018 Wim Van Renterghem. All rights reserved.
//

import Foundation
import MapKit

class ImageOverlay: NSObject, MKOverlay {
    
    let image: UIImage
    let boundingMapRect: MKMapRect
    let coordinate: CLLocationCoordinate2D
	let rotation: CLLocationDirection
    
	init(image: UIImage, rect: MKMapRect, center: CLLocationCoordinate2D, rotation: CLLocationDirection) {
        self.image = image
        self.boundingMapRect = rect
        self.coordinate = center
		self.rotation = rotation
    }
    
//    func canReplaceMapContent() -> Bool {
//        return true
//    }
}

class ImageOverlayRenderer: MKOverlayRenderer {
    
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        
        guard let overlay = self.overlay as? ImageOverlay else {
            return
        }
        
        let rect = self.rect(for: overlay.boundingMapRect)
		
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -rect.size.height)
        context.draw(overlay.image.cgImage!, in: rect)
    }
}
