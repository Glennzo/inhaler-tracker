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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.inhalerVolumeTextField.keyboardType = .decimalPad
        self.inhalerVolumeTextField.text = "\(UserDefaults.standard.value(forKey: InhalerHelper.UserDefaultKey.volume.rawValue) ?? "0")"
    }
        
    @IBAction func closeButton(_ sender: Any) {
        UserDefaults.standard.set(Int(self.inhalerVolumeTextField!.text ?? "0")!, forKey: InhalerHelper.UserDefaultKey.volume.rawValue)
        
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func resetButton(_ sender: Any) {
        UserDefaults.standard.set(0, forKey: InhalerHelper.UserDefaultKey.useage.rawValue)

    }
}
