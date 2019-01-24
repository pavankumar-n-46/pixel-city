//
//  Constants.swift
//  pixel-city
//
//  Created by Pavan Kumar N on 24/01/2019.
//  Copyright © 2019 Pavan Kumar N. All rights reserved.
//

import Foundation

let key = "6df86fafcb3f90b51bbbf9e56eb24af4"
let http = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=598ea619924f3d7a45fce1c1ef41d0b1&lat=12.93&lon=77.60&radius=1&radius_units=km&per_page=40&format=json&nojsoncallback=1"


func flickrUrl(forApi key: String,withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int)->String{
    return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(key)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=km&per_page=\(number)&format=json&nojsoncallback=1"
}
