//
//  UIDatePickerExtension.swift
//  SelfList
//
//  Created by Charles Penunia on 11/12/17.
//  Copyright © 2017 Charles Penunia. All rights reserved.
//

import Foundation
import UIKit

let minuteInterval: Int = 5

extension UIDatePicker {
    func setMinimumDateRoundedUpByMinuteInterval() {
        let secondsInterval = self.minuteInterval * 60
        let intervalRemainder = Int(Date().timeIntervalSinceReferenceDate) % secondsInterval
        let timeInterval = secondsInterval - intervalRemainder
        self.minimumDate = Date(timeIntervalSinceNow: TimeInterval(timeInterval))
    }
}
