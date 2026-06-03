//
//  WaffleLog.swift
//  Waffli
//
//  Created by Ana Linares Guzmán on 23/05/26.
//

import Foundation
import SwiftData

@Model
final class WaffleLog {
    var taskName: String
    var taskCategory: String
    var earnedAt: Date
    var usedToFeed: Bool

    init(taskName: String, taskCategory: WaffliCategory) {
        self.taskName     = taskName
        self.taskCategory = taskCategory.rawValue
        self.earnedAt     = Date()
        self.usedToFeed   = false
    }

    // Waffles ganados hoy (sin usar)
    static func availableToday(from logs: [WaffleLog]) -> Int {
        let cal = Calendar.current
        return logs.filter {
            cal.isDateInToday($0.earnedAt) && !$0.usedToFeed
        }.count
    }
}
