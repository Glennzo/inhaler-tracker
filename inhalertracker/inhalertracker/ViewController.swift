//
//  ViewController.swift
//  inhalertracker
//
//  Created by Glenn Tillemans on 07/04/2019.
//  Copyright © 2019 Magneds B.V. All rights reserved.
//

import UIKit
import HealthKit
import UserNotifications

class ViewController: UIViewController {
    
    @IBOutlet var inhalerCountLabel: UILabel!
    @IBOutlet var inhalerStatusLabel: UILabel!
    @IBOutlet var inhalerStepper: UIStepper!
    
    var inhalerCount: Int = 1    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authorizeHealthKit()
        authorizeNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    private func authorizeNotifications() {
        let options: UNAuthorizationOptions = [.alert, .sound];

        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            guard granted else {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else {
                    print("Error")
                }
                return
            }
            print("Notifications Sucessfully Authorized.")
        }
    }
    
    private func updateInhalerStatus() -> String {
        if let userDefaults = UserDefaults(suiteName: "group.inhalertracker") {
            let inhalerVolumeCount: Int = userDefaults.integer(forKey: InhalerHelper.UserDefaultKey.volume.rawValue)
            let inhalerUseages: Int = userDefaults.integer(forKey: InhalerHelper.UserDefaultKey.useage.rawValue)
        
            return "\(inhalerVolumeCount - inhalerUseages) / \(inhalerVolumeCount)"
        }
        
        return ""
    }
    
    private func checkInhalerStatus() {
        if let userDefaults = UserDefaults(suiteName: "group.inhalertracker") {
            let inhalerVolumeCount: Int = userDefaults.integer(forKey: InhalerHelper.UserDefaultKey.volume.rawValue)
            let inhalerUseages: Int = userDefaults.integer(forKey: InhalerHelper.UserDefaultKey.useage.rawValue)
            let inhalerNotification: Int = userDefaults.integer(forKey: InhalerHelper.UserDefaultKey.notification.rawValue)

            let remainingUseages = inhalerVolumeCount - inhalerUseages
            
            if (remainingUseages <= inhalerNotification) {
                sendNotification()
            }
        }
    }
    
    private func sendNotification() {
        var charges = "a few"
        var identifier = "inhalertracker.notification.id.0"
        if let userDefaults = UserDefaults(suiteName: "group.inhalertracker") {
            let inhalerVolumeCount: Int = userDefaults.integer(forKey: InhalerHelper.UserDefaultKey.volume.rawValue)
            let inhalerUseages: Int = userDefaults.integer(forKey: InhalerHelper.UserDefaultKey.useage.rawValue)
            
            charges = "\(inhalerVolumeCount - inhalerUseages)"
            identifier = "inhalertracker.notification.id.\(inhalerUseages))"
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Your Inhaler is almost empty"
        content.body = "You only have \(charges) charges left from your inhaler. Time to order a new one."
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60,
                                                        repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    @IBAction func inhalerCountStepper(_ sender: UIStepper) {
        self.inhalerCount = Int(sender.value)
        self.inhalerCountLabel.text = inhalerCount.description
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
                    if let userDefaults = UserDefaults(suiteName: "group.inhalertracker") {
                        var useages: Int = userDefaults.integer(forKey: InhalerHelper.UserDefaultKey.useage.rawValue)
                        useages = useages + self.inhalerCount
                        userDefaults.set(useages, forKey: InhalerHelper.UserDefaultKey.useage.rawValue)
                    }
                    self.inhalerCount = 1;
                    self.inhalerCountLabel.text = self.inhalerCount.description
                    self.inhalerStatusLabel.text = "\(self.updateInhalerStatus())"
                    self.inhalerStepper.value = Double(self.inhalerCount)
                    
                    self.checkInhalerStatus()
                }
            }
        }
    }
    
    @IBAction func settingsButton(_ sender: Any) {
        let vc: UIViewController = (self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController"))!
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
}

