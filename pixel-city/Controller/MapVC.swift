//
//  MapVC.swift
//  pixel-city
//
//  Created by Pavan Kumar N on 22/01/2019.
//  Copyright © 2019 Pavan Kumar N. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self 
    }
    
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
    }
    
}

extension MapVC: MKMapViewDelegate{
    
}
