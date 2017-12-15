//
//  TaskMOExtension.swift
//  SelfList
//
//  Created by Charles Penunia on 11/13/17.
//  Copyright © 2017 Charles Penunia. All rights reserved.
//

import Foundation
import CoreData

let rate: Float = 1.0
let secondsPerWeek: Float = 60 * 60 * 24 * 7

extension TaskMO {
    func updateDynamicPriority() {
        // Use for deployment
        let xValue = Float(Date().timeIntervalSince(self.startDate!)) / secondsPerWeek
        
        // Use for testing
        //let xValue = Float(Date().timeIntervalSince(self.startDate!)) / 60
        
        self.dynamicPriority = 1.0 - (1.0 - self.priority) * expf(-1.0 * rate * xValue)
    }
}
