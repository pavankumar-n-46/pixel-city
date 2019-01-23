//
//  DroppablePin.swift
//  pixel-city
//
//  Created by Pavan Kumar N on 23/01/2019.
//  Copyright © 2019 Pavan Kumar N. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin : NSObject, MKAnnotation{
    dynamic var coordinate : CLLocationCoordinate2D
    var identifier : String
    
    init(coordinate:CLLocationCoordinate2D,identifier:String){
        self.coordinate = coordinate
        self.identifier = identifier
    }
}
