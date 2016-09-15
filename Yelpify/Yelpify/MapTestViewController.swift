//
//  MapTestViewController.swift
//  Yelpify
//
//  Created by Jonathan Lam on 9/2/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import GoogleMaps

class MapTestViewController: UIViewController {

    @IBOutlet var mapView: UIView!
    
    override func loadView() {
        super.loadView()
        let camera = GMSCameraPosition.camera(withLatitude: 1.285, longitude: 103.848, zoom: 12)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        self.view = mapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
}
