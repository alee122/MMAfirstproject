//
//  Map.swift
//  PedestrianSafetyApp
//
//  Created by Sophie on 2/19/16.
//  Copyright © 2016 Tufts University. All rights reserved.
//

import UIKit
import MapKit

class MarkedLocation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var info: String
    var region: CLCircularRegion
    var notif: UILocalNotification
    var overlay: MKCircle
    var displayedNotif: Bool
    
    init(coordinate: CLLocationCoordinate2D, info: String, region: CLCircularRegion, notif: UILocalNotification, overlay: MKCircle, displayedNotif: Bool) {
        self.coordinate = coordinate
        self.info = info
        self.region = region
        self.notif = notif
        self.overlay = overlay
        self.displayedNotif = displayedNotif
    }

}
