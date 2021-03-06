//
//  TodayViewController.swift
//  inhalertracker-widget
//
//  Created by Glenn Tillemans on 07/04/2019.
//  Copyright © 2019 Magneds B.V. All rights reserved.
//

import UIKit
import NotificationCenter
import HealthKit
import UserNotifications

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet var inhalerCountLabel: UILabel!
    @IBOutlet var inhalerStatusLabel: UILabel!
    @IBOutlet var inhalerStepper: UIStepper!
    
    var inhalerCount: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        self.inhalerStatusLabel.text = "\(self.updateInhalerStatus())"
        self.inhalerStepper.value = Double(self.inhalerCount)
        
        completionHandler(NCUpdateResult.newData)
    }
    
    private func updateInhalerStatus() -> String {
        if let userDefaults = UserDefaults(suiteName: "group.inhalertracker") {
            let inhalerVolumeCount: Int = userDefaults.integer(forKey: "inhalerVolumeCount")
            let inhalerUseages: Int = userDefaults.integer(forKey: "inhalerUsages")
            
            return "\(inhalerVolumeCount - inhalerUseages) / \(inhalerVolumeCount)"
        }
        
        return ""
    }
    
    private func checkInhalerStatus() {
        if let userDefaults = UserDefaults(suiteName: "group.inhalertracker") {
            let inhalerVolumeCount: Int = userDefaults.integer(forKey: "inhalerVolumeCount")
            let inhalerUseages: Int = userDefaults.integer(forKey: "inhalerUsages")
            let inhalerNotification: Int = userDefaults.integer(forKey: "inhalerNotification")
            
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
            let inhalerVolumeCount: Int = userDefaults.integer(forKey: "inhalerVolumeCount")
            let inhalerUseages: Int = userDefaults.integer(forKey: "inhalerUsages")
            
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
       
        guard let inhalerUsage = HKObjectType.quantityType(forIdentifier: .inhalerUsage) else {
            print("InhalerUsage type not available on this device.")
            return
        }
        
        // Transform the inhalerCount variable in to a HealthKit quanitity
        let dataPoint = HKQuantity(unit: HKUnit(from: "count"), doubleValue: Double(inhalerCount))
        
        // Log to HealthKit
        let quantitySample = HKQuantitySample(type: inhalerUsage, quantity: dataPoint, start: Date(), end: Date())
        
        let healthStore = HKHealthStore()
        healthStore.save(quantitySample) { (success, error) in
            if let error = error {
                print ("Error saving inhaler usage: \(error.localizedDescription)")
            } else {
                print ("Successfully saved inhaler usage!")
                DispatchQueue.main.async {
                    if let userDefaults = UserDefaults(suiteName: "group.inhalertracker") {
                        var useages: Int = userDefaults.integer(forKey: "inhalerUsages")
                        useages = useages + self.inhalerCount
                        userDefaults.set(useages, forKey: "inhalerUsages")
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
    
}
