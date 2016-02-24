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
    
    // Array of user created pinpoints
    var userPinpoints : [MarkedLocation] = []
    
    var timer = NSTimer()

    @IBOutlet var tap: UITapGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Location Manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        
        // MapKit setup
        let span = MKCoordinateSpanMake(0.01, 0.01)
        var region = MKCoordinateRegion()
        region.span = span
        region.center = locationManager.location!.coordinate
        
        mapView.setRegion(region, animated: true)
        mapView.addGestureRecognizer(gestureRecognizer)
        
        
        flashlightButton.setTitle("Turn on light", forState: .Normal)
        flashlightButton.backgroundColor = UIColor(red: 0, green: 51/255, blue: 204/255, alpha: 1)
        flashlightButton.setTitleColor(UIColor(red: 153/255, green: 214/255, blue: 1, alpha: 1), forState: .Normal)
        

        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleTap(gestureRecognizer:UITapGestureRecognizer) {
        let touchLocation = gestureRecognizer.locationInView(mapView)
        let locationCoordinate = mapView.convertPoint(touchLocation, toCoordinateFromView: mapView)
        
        // Check if the user is deleting a point
        for pinpoint in userPinpoints {
            if (pinpoint.region.containsCoordinate(locationCoordinate)) {
                if let itemToRemoveIndex = userPinpoints.indexOf(pinpoint) {
                    userPinpoints.removeAtIndex(itemToRemoveIndex)
                }
                mapView.removeAnnotation(pinpoint)
                mapView.removeOverlay(pinpoint.overlay)
                return
            }
        }
        
        // Create region surrounding point
        let center:CLLocationCoordinate2D = CLLocationCoordinate2DMake(locationCoordinate.latitude, locationCoordinate.longitude)
        let radius:CLLocationDistance = CLLocationDistance(25.0)
        let identifier:String = "pin region"
        let geoRegion:CLCircularRegion = CLCircularRegion(center: center, radius: radius, identifier: identifier)
        geoRegion.notifyOnEntry = true // Only notify when a user enters the region
        let circleRegion:MKCircle = MKCircle(centerCoordinate:center, radius: radius)
        
        // Build notification object for given point
        let notification = UILocalNotification()
        notification.alertBody = "You're entering an area you marked as dangerous - would you like to turn on the safety light?"
        notification.alertAction = "Open"
    
        // The built-in didEnterRegion method was too inconsistent for demo purposes
        //notification.region = geoRegion
        //UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        // Create the MarkedLocation object
        let pin = MarkedLocation(coordinate: CLLocationCoordinate2D(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude), info: "Pinpoint created by the user", region: geoRegion, notif: notification, overlay: circleRegion, displayedNotif: false)
        
        // Store location marked by user, add to map
        userPinpoints.append(pin)
        mapView.addAnnotation(pin)
        mapView.addOverlay(circleRegion)
    }
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        print("Starting monitoring \(region.identifier)")
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered Region \(region.identifier)")
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor(red: 221/255, green: 35/255, blue: 68/255, alpha: 1)
            circle.fillColor = UIColor(red: 221/255, green: 35/255, blue: 68/255, alpha: 0.1)
            circle.lineWidth = 1
            return circle
        } else {
            return nil
        }
    }


    @IBAction func flashlightButton(sender: UIButton) {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        if (lightIsOn) {
            timer.invalidate()
            do {
                try device.lockForConfiguration()
                device.torchMode = AVCaptureTorchMode.Off
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
            sender.setTitle("Turn on light", forState: .Normal)
            sender.backgroundColor = UIColor(red: 0, green: 51/255, blue: 204/255, alpha: 1)
            sender.setTitleColor(UIColor(red: 153/255, green: 214/255, blue: 1, alpha: 1), forState: .Normal)
            lightIsOn = !lightIsOn
        } else {
            timer.invalidate()
            do {
                try device.lockForConfiguration()
                device.torchMode = AVCaptureTorchMode.On
                lightIsOn = !lightIsOn
                timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "toggleFlash", userInfo: nil, repeats: true)
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
            sender.backgroundColor = UIColor(red: 153/255, green: 214/255, blue: 1, alpha: 1)
            sender.setTitleColor(UIColor(red: 0, green: 51/255, blue: 204/255, alpha: 1), forState: .Normal)
            sender.setTitle("Turn off light", forState: .Normal)

        }
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute], fromDate: date)
        let hr = components.hour
        let mins = components.minute
        
        // Checks if in sunset time range and that app is in background (we only display notifs if in background)
        if (isDark(hr, minute: mins) && UIApplication.sharedApplication().applicationState == .Background) {
            for pinpoint in userPinpoints {
                if (pinpoint.region.containsCoordinate(locValue) && !pinpoint.displayedNotif) {
                    let notification = pinpoint.notif
                    UIApplication.sharedApplication().presentLocalNotificationNow(notification)
                    // This should probably be on a timer in the future
                    // Right now, we display the notification only once
                    pinpoint.displayedNotif = true
                }
            }
        }
    }
    
    func isDark(hour: Int, minute: Int) -> Bool {
        // In the future, would use API to fetch specific sunset data
        if ((hour >= 5 && hour <= 23) || (hour >= 0 && hour <= 7)) {
            return true
        }
        return false
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
