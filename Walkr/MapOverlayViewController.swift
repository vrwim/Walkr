//
//  MapOverlayViewController.swift
//  Walkr
//
//  Created by Wim Van Renterghem on 12/03/2018.
//  Copyright © 2018 Wim Van Renterghem. All rights reserved.
//

import UIKit
import MapKit
import ALCameraViewController

class MapOverlayViewController: UIViewController {
    
    var image: UIImage!
	
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var doneButton: UIButton!
	@IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
	
	let control = UISlider()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupView()
    }

    @IBAction func doneTapped() {
		if let image = image {
			mapView.alpha = 1
			
			let imageAspectRatio = Double(image.size.height / image.size.width)
			
			var mapRect = mapView.visibleMapRect
			let heightChange = mapRect.size.width * Double(imageAspectRatio) - mapRect.size.height
			mapRect.size.height = mapRect.size.width * Double(imageAspectRatio)
			mapRect.origin.y -= heightChange / 2
			
			mapView.add(ImageOverlay(image: image, rect: mapRect, center: mapView.centerCoordinate))
			
			navigationItem.titleView = nil
			
			self.image = nil
			
			doneButton.setTitle("Pick another", for: .normal)
		} else {
			let cameraViewController = CameraViewController { [weak self] image, asset in
				if let image = image {
					self?.image = image
					
					self?.setupView()
				}
				
				self?.dismiss(animated: true, completion: nil)
			}
			
			present(cameraViewController, animated: true, completion: nil)
			
			doneButton.setTitle("Done", for: .normal)
		}
    }
	
	@objc func valueChanged(sender: UISlider) {
		mapView.alpha = CGFloat(sender.value)
	}
	
	func setupView() {
		imageView.image = image
		imageViewHeightConstraint.constant = UIScreen.main.bounds.width * image.size.height / image.size.width
		
		mapView.alpha = 0.5
		mapView.showsUserLocation = true
		mapView.delegate = self
		
		control.value = 0.5
		control.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
		navigationItem.titleView = control
	}
}

extension MapOverlayViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return ImageOverlayRenderer(overlay: overlay)
    }
}
