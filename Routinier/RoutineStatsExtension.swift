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
        let created = createdAt
        let completions = self.completions
        if completions.isEmpty { return 0.0 }

        let calendar = Calendar.current
        let now = Date()
        var expectedDates: [Date] = []
        var next = firstDue

        while next <= now {
            expectedDates.append(next)
            switch recurrenceType {
            case "interval":
                next = calendar.date(byAdding: .day, value: Int(recurrenceValue), to: next) ?? next
            case "weekly":
                next = calendar.date(byAdding: .weekOfYear, value: 1, to: next) ?? next
            case "monthly":
                next = calendar.date(byAdding: .month, value: 1, to: next) ?? next
            case "yearly":
                next = calendar.date(byAdding: .year, value: 1, to: next) ?? next
            default:
                break
            }
        }

        // Match completions to expected dates within ±24h
        let margin: TimeInterval = 24 * 60 * 60
        var matched = 0

        for dueDate in expectedDates {
            if completions.contains(where: { abs($0.timestamp.timeIntervalSince(dueDate)) <= margin }) {
                matched += 1
            }
        }

        guard !expectedDates.isEmpty else { return 0.0 }
        return Double(matched) / Double(expectedDates.count)
    }

    var completionCount: Int {
        return (self.completions as? Set<Completion>)?.count ?? 0
    }
}
