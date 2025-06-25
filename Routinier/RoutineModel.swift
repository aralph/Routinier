//
//  RoutineModel.swift
//  Routinier
//

import Foundation
import CoreData

@objc(Routine)
public class Routine: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var descriptionText: String?
    @NSManaged public var category: String?
    @NSManaged public var recurrenceType: String  // "interval" or "calendar"
    @NSManaged public var recurrenceValue: Int32  // number of days or day of month
    @NSManaged public var firstDueDate: Date?
    @NSManaged public var nextDueDate: Date
    @NSManaged public var createdAt: Date
    @NSManaged public var completions: Set<Completion>
}

@objc(Completion)
public class Completion: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var timestamp: Date
    @NSManaged public var routine: Routine
}

// MARK: - Convenience Methods

extension Routine {
    public func markCompleted(at date: Date = Date()) {
        let completion = Completion(context: self.managedObjectContext!)
        completion.id = UUID()
        completion.timestamp = date
        completion.routine = self

        self.completions.insert(completion)

        // Calculate next due date
        switch self.recurrenceType {
        case "interval":
            self.nextDueDate = Calendar.current.date(byAdding: .day, value: Int(self.recurrenceValue), to: date) ?? date
        case "calendar":
            let next = Calendar.current.date(byAdding: .month, value: 1, to: date) ?? date
            let comps = Calendar.current.dateComponents([.year, .month], from: next)
            self.nextDueDate = Calendar.current.date(from: DateComponents(year: comps.year, month: comps.month, day: Int(self.recurrenceValue))) ?? next
        default:
            self.nextDueDate = date
        }
    }
}

extension Routine: Identifiable {}
extension Completion: Identifiable {}
