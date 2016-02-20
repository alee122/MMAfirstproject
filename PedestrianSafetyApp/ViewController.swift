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
    var notification:UILocalNotification = UILocalNotification()
    
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
        
        notification.alertBody = "Hello"
        notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        
        
        let london = Location(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics.")
        let oslo = Location(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.")
        let paris = Location(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the City of Light.")
        let rome = Location(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.")
        let washington = Location(title: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself.")
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        mapView.addGestureRecognizer(gestureRecognizer)
        mapView.addAnnotations([london, oslo, paris, rome, washington])
        
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
        print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
    }

    @IBAction func flashlightButton(sender: UIButton) {
        if (lightIsOn) {
            print("turning off flash!")            
            //turn off light
            toggleFlash()
            sender.setTitle("Turn on flashlight", forState: .Normal)
            lightIsOn = !lightIsOn
        } else {
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
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
