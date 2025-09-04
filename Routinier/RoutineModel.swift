//
//  RoutineModel.swift
//  Routinier
//

import Foundation
import CoreData

@objc(Routine)
public class Routine: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var descriptionText: String?
    @NSManaged public var category: String?
    @NSManaged public var recurrenceType: String?  // "interval", "yearly", "monthly", "weekly"
    @NSManaged public var recurrenceValue: Int32  // number of days or day of month
    @NSManaged public var hour: Int16
    @NSManaged public var minute: Int16
    @NSManaged public var firstDueDate: Date?
    @NSManaged public var nextDueDate: Date?
    @NSManaged public var createdAt: Date?
    @NSManaged public var completions: Set<Completion>
    
    // Sharing properties
    @NSManaged public var isShared: Bool
    @NSManaged public var lastModified: Date?
    @NSManaged public var ownerId: String?
    @NSManaged public var cloudKitShareData: Data?
}

@objc(Completion)
public class Completion: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var timestamp: Date?
    @NSManaged public var routine: Routine?
}

// MARK: - Convenience Methods

extension Routine {
    public func markCompleted(at date: Date = Date()) {
        guard let context = self.managedObjectContext else {
            print("ERROR: Cannot mark completion - no managed object context")
            return
        }
        
        let completion = Completion(context: context)
        completion.id = UUID()
        completion.timestamp = date
        completion.routine = self

        self.completions.insert(completion)

        // Calculate next due date
        guard let recurrenceType = self.recurrenceType else {
            print("Warning: Routine has no recurrence type, skipping next due date calculation")
            return
        }
        
        switch recurrenceType {
        case "interval":
            self.nextDueDate = Calendar.current.date(byAdding: .day, value: Int(self.recurrenceValue), to: date) ?? date
        case "monthly":
            // TODO hardcoded to monthly from original version
            let next = Calendar.current.date(byAdding: .month, value: 1, to: date) ?? date
            let comps = Calendar.current.dateComponents([.year, .month], from: next)
            self.nextDueDate = Calendar.current.date(from: DateComponents(year: comps.year, month: comps.month, day: Int(self.recurrenceValue))) ?? next
        default:
            print("Warning: Unknown recurrence type '\(recurrenceType)', skipping next due date calculation")
            return
        }
        
        // Update last modified for CloudKit sync
        self.lastModified = date
    }
}

// MARK: - Sharing Extensions

extension Routine {
    /// Whether this routine can be shared
    var canBeShared: Bool {
        return !isShared && CloudKitManager.shared.canShare(routine: self)
    }
    
    /// Whether this routine is currently shared with others
    var isCurrentlyShared: Bool {
        return isShared && cloudKitShareData != nil
    }
    
    /// Number of participants in this shared routine (stub)
    var participantCount: Int {
        // TODO: Extract from cloudKitShareData when available
        return isShared ? 2 : 1 // Placeholder: owner + 1 participant
    }
    
    /// URL for sharing this routine (if shared)
    var shareURL: URL? {
        guard isShared else { return nil }
        return CloudKitManager.shared.getSharingURL(for: self)
    }
    
    /// Display text for sharing status
    var sharingStatusText: String {
        if isShared {
            let count = participantCount
            return count > 1 ? "Shared with \(count - 1) people" : "Shared"
        } else {
            return "Private"
        }
    }
    
    /// Safe access to routine name
    var displayName: String {
        return name ?? "Unnamed Routine"
    }
    
    /// Icon name for sharing status
    var sharingStatusIcon: String {
        return isShared ? "person.2.fill" : "person.fill"
    }
    
    /// Color for sharing status
    var sharingStatusColor: String {
        return isShared ? "blue" : "gray"
    }
    
    /// Whether the current user owns this routine
    var isOwnedByCurrentUser: Bool {
        let currentOwnerID = CloudKitManager.shared.getCurrentOwnerID()
        return ownerId == nil || ownerId == currentOwnerID
    }
    
    /// Prepares routine for sharing by setting initial share properties
    func prepareForSharing() {
        guard !isShared else { return }
        
        isShared = true
        ownerId = CloudKitManager.shared.getCurrentOwnerID()
        lastModified = Date()
    }
    
    /// Marks routine as no longer shared
    func stopSharing() {
        isShared = false
        cloudKitShareData = nil
        lastModified = Date()
    }
}

extension Routine: Identifiable {}
extension Completion: Identifiable {}
