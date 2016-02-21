//
//  ViewController.swift
//  PedestrianSafetyApp
//
//  Created by Alice Lee on 2/9/16.
//  Copyright © 2016 Tufts University. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var flashlightButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    var lightIsOn = false;
    var locationManager:CLLocationManager!
    //var notification:UILocalNotification = UILocalNotification()
    
    // Array of user created pinpoints
    var userPinpoints : [MarkedLocation] = []
    var notifications : [UILocalNotification] = []
    
    @IBOutlet var tap: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        
        // Location Manager (for getting sunset data)
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        let span = MKCoordinateSpanMake(0.01, 0.01)
        var region = MKCoordinateRegion()
        region.span = span
        region.center = locationManager.location!.coordinate
        mapView.setRegion(region, animated: true)
        mapView.addGestureRecognizer(gestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleTap(gestureRecognizer:UITapGestureRecognizer) {
        print("Registering tap")
        let touchLocation = gestureRecognizer.locationInView(mapView)
        print(touchLocation)
        let locationCoordinate = mapView.convertPoint(touchLocation, toCoordinateFromView: mapView)
        
        // Check if the user is deleting a point
        for pinpoint in userPinpoints {
            if (pinpoint.region.containsCoordinate(locationCoordinate)) {
                if let itemToRemoveIndex = userPinpoints.indexOf(pinpoint) {
                    userPinpoints.removeAtIndex(itemToRemoveIndex)
                }
                print(userPinpoints)
                mapView.removeAnnotation(pinpoint)
                mapView.removeOverlay(pinpoint.overlay)
                return
            }
        }
        
        // Create region surrounding point
        let center:CLLocationCoordinate2D = CLLocationCoordinate2DMake(locationCoordinate.latitude, locationCoordinate.longitude)
        let radius:CLLocationDistance = CLLocationDistance(200.0)
        let identifier:String = "pin region"
        let geoRegion:CLCircularRegion = CLCircularRegion(center: center, radius: radius, identifier: identifier)
        geoRegion.notifyOnEntry = true // Only notify when a user enters the region
        let circleRegion:MKCircle = MKCircle(centerCoordinate:center, radius: radius)
        
        // Build notification object for given point
        let notification = UILocalNotification()
        notification.alertBody = "You're entering an area you marked as dangerous - would you like to turn on the safety light?"
        notification.alertAction = "open"
        notification.region = geoRegion
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        notifications.append(notification)
        print(notifications)
        
        // Create the MarkedLocation object
        let pin = MarkedLocation(coordinate: CLLocationCoordinate2D(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude), info: "Pinpoint created by the user", region: geoRegion, notif: notification, overlay: circleRegion)
        
        // Store location marked by user, add to map
        userPinpoints.append(pin)
        mapView.addAnnotation(pin)
        mapView.addOverlay(circleRegion)
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.redColor()
            circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
            circle.lineWidth = 1
            return circle
        } else {
            return nil
        }
    }


    @IBAction func flashlightButton(sender: UIButton) {
        if (lightIsOn) {
            print("turning off flash!")            
            //turn off light
            toggleFlash()
            sender.setTitle("Turn on flashlight", forState: .Normal)
            lightIsOn = !lightIsOn
        } else {
            print("turning on flash!")
            //turn on light
            toggleFlash()
            sender.setTitle("Turn off flashlight", forState: .Normal)
            lightIsOn = !lightIsOn
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        //print("Current location is = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func toggleFlash() {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if (device.hasTorch) {
            do {
                try device.lockForConfiguration()
                if (device.torchMode == AVCaptureTorchMode.On) {
                    device.torchMode = AVCaptureTorchMode.Off
                } else {
                    do {
                        try device.setTorchModeOnWithLevel(1.0)
                    } catch {
                        print(error)
                    }
                }
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
        
    }

}
