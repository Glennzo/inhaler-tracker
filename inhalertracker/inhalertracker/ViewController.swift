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
    
    @IBOutlet var inhalerCountLabel: UILabel!
    @IBOutlet var inhalerStatusLabel: UILabel!
    @IBOutlet var inhalerStepper: UIStepper!
    
    var inhalerCount: Int = 1    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authorizeHealthKit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.inhalerStatusLabel.text = "\(self.updateInhalerStatus())"
        self.inhalerStepper.value = Double(self.inhalerCount)
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
    
    private func updateInhalerStatus() -> String {
        let inhalerVolumeCount: Int = UserDefaults.standard.integer(forKey: InhalerHelper.UserDefaultKey.volume.rawValue)
        let inhalerUseages: Int = UserDefaults.standard.integer(forKey: InhalerHelper.UserDefaultKey.useage.rawValue)
        
        return "\(inhalerVolumeCount - inhalerUseages) / \(inhalerVolumeCount)"
    }
    
    @IBAction func inhalerCountStepper(_ sender: UIStepper) {
        self.inhalerCount = Int(sender.value)
        self.inhalerCountLabel.text = inhalerCount.description
        self.inhalerStatusLabel.text = "\(self.updateInhalerStatus())"
    }
    
    @IBAction func submitButton(_ sender: Any) {
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        let dateString: String = dateFormatter.string(from: Date())
        
        guard let inhalerUsage = HKObjectType.quantityType(forIdentifier: .inhalerUsage) else {
            print("InhalerUsage type not available on this device.")
            return
        }
        
        // Transform the inhalerCount variable in to a HealthKit quanitity
        let dataPoint = HKQuantity(unit: HKUnit(from: "count"), doubleValue: Double(inhalerCount))
        
        // Log to HealthKit
        print("Logging the following data to HealthKit: \(inhalerCount) puffs at \(dateString)")
        let quantitySample = HKQuantitySample(type: inhalerUsage, quantity: dataPoint, start: Date(), end: Date())
        
        let healthStore = HKHealthStore()
        healthStore.save(quantitySample) { (success, error) in
            if let error = error {
                print ("Error saving inhaler usage: \(error.localizedDescription)")
            } else {
                print ("Successfully saved inhaler usage!")
                DispatchQueue.main.async {
                    UserDefaults.standard.set(self.inhalerCount, forKey: InhalerHelper.UserDefaultKey.useage.rawValue)
                    self.inhalerCount = 1;
                    self.inhalerCountLabel.text = self.inhalerCount.description
                    self.inhalerStatusLabel.text = "\(self.updateInhalerStatus())"
                    self.inhalerStepper.value = Double(self.inhalerCount)
                }
            }
        }
    }
    
    @IBAction func settingsButton(_ sender: Any) {
        let vc: UIViewController = (self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController"))!
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
}

