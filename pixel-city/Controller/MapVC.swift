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
import Alamofire
import AlamofireImage

class MapVC: UIViewController,UIGestureRecognizerDelegate{

    //outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    
    //vars
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    
    var spinner: UIActivityIndicatorView?
    var progressLbl: UILabel?
    let screenSize = UIScreen.main.bounds
    let flowLayout = UICollectionViewFlowLayout()
    var collectionView : UICollectionView?
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        pullUpView.addSubview(collectionView!)
        
    }
    
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSwpie(){
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipeDown.direction = .down
        pullUpView.addGestureRecognizer(swipeDown)
    }
    
    func animateViewUp(){
        pullUpViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addSpinner(){
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width/2)-((spinner?.frame.width)!/2), y: 130 )
        spinner?.style = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func addProgressLbl(){
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: (screenSize.width/2)-120, y: 150, width: 240, height: 40)
        progressLbl?.font = UIFont(name: "Avenir Next", size: 18)
        progressLbl?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        progressLbl?.textAlignment = .center
        collectionView?.addSubview(progressLbl!)
        
    }
    
    func removeSpinner(){
        spinner?.removeFromSuperview()
    }
    
    @objc func animateViewDown(){
        removeSpinner()
        pullUpViewHeightConstraint.constant = 1
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse{
            centerMapOnUserLocation()
        }
    }
    
}



extension MapVC: MKMapViewDelegate{
    
    //customize the drop-pin annotation.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let pinAnnotiation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "dropped_pin")
        pinAnnotiation.pinTintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
        pinAnnotiation.animatesDrop = true
        return pinAnnotiation
    }
    
    func centerMapOnUserLocation(){
        guard let coordinate = locationManager.location?.coordinate else { return print("no location yet!")}
        let coordinateRegion = MKCoordinateRegion(center: coordinate,latitudinalMeters: regionRadius*2.0,longitudinalMeters: regionRadius*2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer){
        //remove all annotations
        removePin()
        //remove spinner
        removeSpinner()
        //remove image URL's
        imageUrlArray.removeAll()
        //remove images
        imageArray.removeAll()
        //reload collection view
        collectionView?.reloadData()
        //convert the touch coordinates of the screen to GPS coordinates from the mapView
        let touchPoint = sender.location(in: mapView)
        let touchPointCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        //put the annotiation on the map screen.
        let annotiation = DroppablePin(coordinate: touchPointCoordinates, identifier: "dropped_pin")
        mapView.addAnnotation(annotiation)
        //center the annotiation point on the map screen.
        let coordinateRegion = MKCoordinateRegion(center: touchPointCoordinates, latitudinalMeters: regionRadius*2.0, longitudinalMeters: regionRadius*2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        //call the requestURL's api
        retrieveUrls(forAnnotation: annotiation) { (finished) in
            if finished{
                self.retrieveImages(handler: { (finished) in
                    if finished{
                        self.spinner?.stopAnimating()
                        self.spinner?.isHidden = true
                        self.progressLbl?.isHidden = true
                        self.collectionView?.reloadData()
                    }
                })
            }
        }
        //bring up the hidden view
        animateViewUp()
        //brings down the hidden view
        addSwpie()
        //addSpinner
        addSpinner()
        //add progress label
        addProgressLbl()
    }
    
    func removePin(){
        for annotation in mapView.annotations{
            mapView.removeAnnotation(annotation)
        }
    }
    
    func retrieveUrls(forAnnotation annotation: DroppablePin, handler: @escaping (_ status:Bool)->()){
        request(flickrUrl(forApi: key, withAnnotation: annotation, andNumberOfPhotos: NUMBER_OF_IMAGES)).responseJSON{ (response) in
            guard let json = response.result.value as? Dictionary<String,AnyObject> else {return}
            let photosDict = json["photos"] as! Dictionary<String,AnyObject>
            let photosDictArray = photosDict["photo"] as! [Dictionary<String,AnyObject>]
            for i in photosDictArray{
                let url = "https://farm\(i["farm"]!).staticflickr.com/\(i["server"]!)/\(i["id"]!)_\(i["secret"]!)_z_d.jpg"
                self.imageUrlArray.append(url)
            }
            print(self.imageUrlArray)
            handler(true)
        }
    }
    
    func retrieveImages(handler:@escaping (Bool)->Void){
        for url in imageUrlArray{
            request(url).responseImage { (response) in
                guard let image = response.result.value else { return }
                self.imageArray.append(image)
                self.progressLbl?.text = "\(self.imageArray.count)/\(self.imageUrlArray.count) Images Loaded"
                if self.imageArray.count == self.imageUrlArray.count{
                    handler(true)
                }
            }
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

extension MapVC: UICollectionViewDelegate,UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //number of items in array
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else { return UICollectionViewCell()}
        let imageFromIndex = imageArray[indexPath.row]
        let imageView = UIImageView(image: imageFromIndex)
        cell.addSubview(imageView)
        return cell
    }
}
