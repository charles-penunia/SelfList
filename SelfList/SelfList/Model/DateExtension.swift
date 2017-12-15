//
//  DateExtension.swift
//  SelfList
//
//  Created by Charles Penunia on 12/1/17.
//  Copyright © 2017 Charles Penunia. All rights reserved.
//

import Foundation

extension Date {
    var components: DateComponents {
        let cal = Calendar.current
        let dateComponentSet: Set<Calendar.Component> = Set([.year, .month, .day, .hour, .minute, .second, .weekday, .weekOfYear, .yearForWeekOfYear])
        return cal.dateComponents(dateComponentSet, from: self)
    }
    
    func getFirstDayOfWeek() -> Date {
        let calendar = Calendar.current
        var newComponents = DateComponents()
        newComponents.calendar = calendar
        newComponents.weekOfYear = self.components.weekOfYear
        newComponents.year = self.components.year
        newComponents.weekday = 1
        return calendar.date(from: newComponents)!
    }
    
    func getDate(byAddingDay day: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: day, to: self)!
    }
    
    func getDate(byAddingWeek week: Int) -> Date {
        return Calendar.current.date(byAdding: .weekOfYear, value: week, to: self)!
    }
}
