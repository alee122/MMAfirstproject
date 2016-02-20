//
//  Map.swift
//  PedestrianSafetyApp
//
//  Created by Sophie on 2/19/16.
//  Copyright © 2016 Tufts University. All rights reserved.
//

import UIKit
import MapKit

class Location: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }

}
