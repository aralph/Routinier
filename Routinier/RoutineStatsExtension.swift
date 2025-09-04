//
//  RoutineStatsExtension.swift
//  Routinier
//
// Adds fulfillment stats to Routine

import Foundation

extension Routine {
    /// Computes how often the routine was completed on time
    /// Returns a value from 0.0 to 1.0
    var fulfillmentRate: Double {
        guard let firstDue = firstDueDate else { return 0.0 }
        let completions = self.completions
        if completions.isEmpty { return 0.0 }

        let calendar = Calendar.current
        let now = Date()
        var expectedDates: [Date] = []
        var nextDueDate = firstDue

        while nextDueDate <= now {
            expectedDates.append(nextDueDate)
            switch recurrenceType {
            case "interval":
                nextDueDate = calendar.date(byAdding: .day, value: Int(recurrenceValue), to: nextDueDate) ?? nextDueDate
            case "weekly":
                nextDueDate = calendar.date(byAdding: .weekOfYear, value: 1, to: nextDueDate) ?? nextDueDate
            case "monthly":
                nextDueDate = calendar.date(byAdding: .month, value: 1, to: nextDueDate) ?? nextDueDate
            case "yearly":
                nextDueDate = calendar.date(byAdding: .year, value: 1, to: nextDueDate) ?? nextDueDate
            default:
                print("Invalid recurrence type \(recurrenceType)")
                return 0.0
            }
        }

        // Match completions to expected dates within ±24h
        let margin: TimeInterval = 24 * 60 * 60
        var matched = 0

        for dueDate in expectedDates {
            if completions.contains(where: { 
                guard let timestamp = $0.timestamp else { return false }
                return abs(timestamp.timeIntervalSince(dueDate)) <= margin 
            }) {
                matched += 1
            }
        }

        guard !expectedDates.isEmpty else { return 0.0 }
        return Double(matched) / Double(expectedDates.count)
    }

    var completionCount: Int {
        return self.completions.count
    }
}
