//
//  ViewController.swift
//  PedestrianSafetyApp
//
//  Created by Alice Lee on 2/9/16.
//  Copyright © 2016 Tufts University. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var flashlightButton: UIButton!
    var lightIsOn = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func flashlightButton(sender: UIButton) {

        if (lightIsOn) {
            print("turning off flash!")            
            //turn off light
            sender.setTitle("TURN ON FLASHLIGHT", forState: .Normal)
            lightIsOn = !lightIsOn
        } else {
            print("turning on flash!")
            //turn on light
            sender.setTitle("TURN OFF FLASHLIGHT", forState: .Normal)
            lightIsOn = !lightIsOn
        }
        
    }

}

