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
    var userPinpoints : [Location] = []
    
    // Array of notifications
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
        let pin = Location(title: "Dangerous area", coordinate: CLLocationCoordinate2D(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude), info: "Pinpoint created by the user")
        
        // Store pin, add to map
        userPinpoints.append(pin)
        mapView.addAnnotation(pin)
        
        let center:CLLocationCoordinate2D = CLLocationCoordinate2DMake(locationCoordinate.latitude, locationCoordinate.longitude)
        let radius:CLLocationDistance = CLLocationDistance(50.0)
        let identifier:String = "pin region"
        let geoRegion:CLCircularRegion = CLCircularRegion(center: center, radius: radius, identifier: identifier)
        
        // Build notification object for point
        let notification = UILocalNotification()
        notification.alertBody = "You're entering an area you marked as dangerous - would you like to turn on the safety light?"
        notification.alertAction = "open"
        notification.region = geoRegion
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        notifications.append(notification)
        
        // Putting circle overlay on map
        let circleRegion:MKCircle = MKCircle(centerCoordinate:center, radius: radius)
        mapView.addOverlay(circleRegion)
        
        print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKCircle {
            var circle = MKCircleRenderer(overlay: overlay)
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
        print("Current location is = \(locValue.latitude) \(locValue.longitude)")
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
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(4.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                        device.torchMode = AVCaptureTorchMode.Off
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(4.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                    device.torchMode = AVCaptureTorchMode.On
                }
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
