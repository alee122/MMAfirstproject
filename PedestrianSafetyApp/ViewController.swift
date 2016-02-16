//
//  ViewController.swift
//  PedestrianSafetyApp
//
//  Created by Alice Lee on 2/9/16.
//  Copyright © 2016 Tufts University. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var flashlightButton: UIButton!
    var lightIsOn = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Ensures that button is always set correctly when app loads after being in background
        flashlightButton.setTitle("Turn on flashlight", forState: .Normal)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
