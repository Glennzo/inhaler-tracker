//
//  HealthKitHelper.swift
//  inhalertracker
//
//  Created by Glenn Tillemans on 07/04/2019.
//  Copyright © 2019 Magneds B.V. All rights reserved.
//

import UIKit

import HealthKit

class HealthKitHelper {
    
    private enum HealthKitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }
    
    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        // Verify that health kit is available on this device
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthKitSetupError.notAvailableOnDevice)
            return
        }
        
        // Define the data types we're using, make sure they're available on this device
        guard let inhalerUsage = HKObjectType.quantityType(forIdentifier: .inhalerUsage) else
        {
            completion(false, HealthKitSetupError.dataTypeNotAvailable)
            return
        }
        
        // Define what we're doing with the data types we just defined
        let typesToWrite: Set<HKSampleType> = [inhalerUsage]
        
        // Request Authorization
        HKHealthStore().requestAuthorization(toShare: typesToWrite, read: nil) { (success, error) in completion(success, error)
            
        }
    }
}
