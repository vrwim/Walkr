//
//  MapOverlayViewController.swift
//  Walkr
//
//  Created by Wim Van Renterghem on 12/03/2018.
//  Copyright © 2018 Wim Van Renterghem. All rights reserved.
//

import UIKit
import MapKit

class MapOverlayViewController: UIViewController {
    
    var image: UIImage!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
        
        mapView.alpha = 0.5
        mapView.showsUserLocation = true
        mapView.delegate = self
        
    }

    @IBAction func doneTapped() {
        mapView.alpha = 1
        
        mapView.add(ImageOverlay(image: image, rect: mapView.visibleMapRect, center: mapView.centerCoordinate))
    }
}
extension MapOverlayViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return ImageOverlayRenderer(overlay: overlay)
    }
}
