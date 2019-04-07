//
//  SettingsViewController.swift
//  inhalertracker
//
//  Created by Glenn Tillemans on 07/04/2019.
//  Copyright © 2019 Magneds B.V. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet var inhalerVolumeTextField: UITextField!
    @IBOutlet var inhalerNotificationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.inhalerVolumeTextField.keyboardType = .decimalPad
        self.inhalerNotificationTextField.keyboardType = .decimalPad

        if let userDefaults = UserDefaults(suiteName: "group.inhalertracker") {
            self.inhalerVolumeTextField.text = "\(userDefaults.value(forKey: InhalerHelper.UserDefaultKey.volume.rawValue) ?? "0")"
            self.inhalerNotificationTextField.text = "\(userDefaults.value(forKey: InhalerHelper.UserDefaultKey.notification.rawValue) ?? "0")"

        }
        

    }
        
    @IBAction func closeButton(_ sender: Any) {
        if let userDefaults = UserDefaults(suiteName: "group.inhalertracker") {
            userDefaults.set(Int(self.inhalerVolumeTextField!.text ?? "0")!, forKey: InhalerHelper.UserDefaultKey.volume.rawValue)
            userDefaults.set(Int(self.inhalerNotificationTextField!.text ?? "0")!, forKey: InhalerHelper.UserDefaultKey.notification.rawValue)

        }
        
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func resetButton(_ sender: Any) {
        if let userDefaults = UserDefaults(suiteName: "group.inhalertracker") {
            userDefaults.set(0, forKey: InhalerHelper.UserDefaultKey.useage.rawValue)
        }

    }
}
