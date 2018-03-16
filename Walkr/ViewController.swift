//
//  ViewController.swift
//  Walkr
//
//  Created by Wim Van Renterghem on 12/03/2018.
//  Copyright © 2018 Wim Van Renterghem. All rights reserved.
//

import UIKit
import ALCameraViewController
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var takeImageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// For use in foreground
		CLLocationManager().requestWhenInUseAuthorization()
    }
    
    @IBAction func pickImage() {
        let cameraViewController = CameraViewController { [weak self] image, asset in
            if let image = image {
                let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mapOverlayVC") as! MapOverlayViewController
                nextVC.image = image

                self?.navigationController?.pushViewController(nextVC, animated: false)
            }
            
            self?.dismiss(animated: true, completion: nil)
        }
        
        present(cameraViewController, animated: true, completion: nil)
    }
}
