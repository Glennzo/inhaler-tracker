//
//  ViewController.swift
//  inhalertracker
//
//  Created by Glenn Tillemans on 07/04/2019.
//  Copyright © 2019 Magneds B.V. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        authorizeHealthKit()
    }

    private func authorizeHealthKit() {
        HealthKitHelper.authorizeHealthKit { (authorized, error) in
            guard authorized else {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else {
                    print("Error")
                }
                return
            }
            print("HealthKit Successfully Authorized.")
        }
    }

}

