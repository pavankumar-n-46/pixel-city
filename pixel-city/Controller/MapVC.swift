//
//  MapVC.swift
//  pixel-city
//
//  Created by Pavan Kumar N on 22/01/2019.
//  Copyright © 2019 Pavan Kumar N. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController,UIGestureRecognizerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
    }
    
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse{
            centerMapOnUserLocation()
        }
    }
    
}

extension MapVC: MKMapViewDelegate{
    
    func centerMapOnUserLocation(){
        guard let coordinate = locationManager.location?.coordinate else { return print("no location yet!")}
        let coordinateRegion = MKCoordinateRegion(center: coordinate,latitudinalMeters: regionRadius*2.0,longitudinalMeters: regionRadius*2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer){
        //remove all annotations
        removePin()
        //convert the touch coordinates of the screen to GPS coordinates from the mapView
        let touchPoint = sender.location(in: mapView)
        let touchPointCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        //put the annotiation on the map screen.
        let annotiation = DroppablePin(coordinate: touchPointCoordinates, identifier: "dropped_pin")
        mapView.addAnnotation(annotiation)
        //center the annotiation point on the map screen.
        let coordinateRegion = MKCoordinateRegion(center: touchPointCoordinates, latitudinalMeters: regionRadius*2.0, longitudinalMeters: regionRadius*2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func removePin(){
        for annotation in mapView.annotations{
            mapView.removeAnnotation(annotation)
        }
    }
    
}

extension MapVC: CLLocationManagerDelegate{
    func configureLocationServices(){
        if authorizationStatus == .notDetermined{
            locationManager.requestAlwaysAuthorization()
        }else{
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}
