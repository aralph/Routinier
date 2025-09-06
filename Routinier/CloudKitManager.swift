//
//  CloudKitManager.swift
//  Routinier
//
//  CloudKit integration manager for shared routines

import Foundation
import CloudKit
import CoreData
import UIKit

class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()
    
    @Published var isCloudKitEnabled = false
    @Published var syncStatus: SyncStatus = .unknown
    
    enum SyncStatus {
        case unknown
        case available
        case unavailable
        case syncing
        case error(Error)
    }
    
    enum CloudKitError: Error, LocalizedError {
        case credentialsNotAvailable
        case sharingNotSupported
        case recordNotFound
        case networkUnavailable
        
        var errorDescription: String? {
            switch self {
            case .credentialsNotAvailable:
                return "CloudKit credentials not available"
            case .sharingNotSupported:
                return "Sharing not supported on this device"
            case .recordNotFound:
                return "Record not found"
            case .networkUnavailable:
                return "Network unavailable"
            }
        }
    }
    
    private init() {
        checkCloudKitAvailability()
    }
    
    // MARK: - CloudKit Availability
    
    private func checkCloudKitAvailability() {
        // Use the known container identifier directly to avoid circular dependency
        let container = CKContainer(identifier: "iCloud.com.aralph.Routinier")
        
        container.accountStatus { [weak self] status, error in
            Task { @MainActor in
                switch status {
                case .available:
                    self?.isCloudKitEnabled = true
                    self?.syncStatus = .available
                case .noAccount, .restricted, .couldNotDetermine:
                    self?.isCloudKitEnabled = false
                    self?.syncStatus = .unavailable
                case .temporarilyUnavailable:
                    self?.isCloudKitEnabled = false
                    self?.syncStatus = .unavailable
                @unknown default:
                    self?.isCloudKitEnabled = false
                    self?.syncStatus = .unavailable
                }
                
                if let error = error {
                    self?.syncStatus = .error(error)
                    print("CloudKit account status error: \(error)")
                }
            }
        }
    }
    
    // MARK: - Sharing Operations (Stubs)
    
    /// Creates a CloudKit share for a routine
    func createShare(for routine: Routine) async throws -> CKShare {
        guard isCloudKitEnabled else {
            throw CloudKitError.credentialsNotAvailable
        }
        
        guard let context = routine.managedObjectContext,
              let persistentStore = context.persistentStoreCoordinator?.persistentStores.first else {
            throw CloudKitError.recordNotFound
        }
        
        // Get the NSPersistentCloudKitContainer from the PersistenceController
        let persistentContainer = PersistenceController.shared.container as? NSPersistentCloudKitContainer
        guard let container = persistentContainer else {
            throw CloudKitError.recordNotFound
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            // Use NSPersistentCloudKitContainer.share() method
            container.share([routine], to: nil) { (objectIDs, share, containerResult, error) in
                if let error = error {
                    print("Failed to create share: \(error.localizedDescription)")
                    print("Error domain: \(error._domain), code: \(error._code)")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let share = share else {
                    print("No share returned from container.share()")
                    continuation.resume(throwing: CloudKitError.sharingNotSupported)
                    return
                }
                
                // Configure the share
                share[CKShare.SystemFieldKey.title] = "Shared routine: \(routine.displayName)" as CKRecordValue
                share.publicPermission = CKShare.ParticipantPermission.none // Private share
                
                // Persist the share update
                container.persistUpdatedShare(share, in: persistentStore) { (updatedShare, persistError) in
                    if let persistError = persistError {
                        print("Failed to persist updated share: \(persistError)")
                        continuation.resume(throwing: persistError)
                        return
                    }
                    
                    // Store share data in routine
                    context.perform {
                        if let shareData = try? NSKeyedArchiver.archivedData(withRootObject: share, requiringSecureCoding: true) {
                            routine.cloudKitShareData = shareData
                            routine.isShared = true
                            routine.lastModified = Date()
                            try? context.save()
                        }
                        
                        print("Successfully created share for routine: \(routine.displayName)")
                        continuation.resume(returning: share)
                    }
                }
            }
        }
    }
    
    /// Accepts a shared routine invitation
    func acceptShare(with metadata: CKShare.Metadata) async throws {
        guard isCloudKitEnabled else {
            throw CloudKitError.credentialsNotAvailable
        }
        
        // TODO: Implement share acceptance
        print("Accepting share invitation")
        throw CloudKitError.sharingNotSupported
    }
    
    /// Removes sharing from a routine
    func stopSharing(routine: Routine) async throws {
        guard isCloudKitEnabled else {
            throw CloudKitError.credentialsNotAvailable
        }
        
        guard let context = routine.managedObjectContext,
              let shareData = routine.cloudKitShareData,
              let share = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKShare.self, from: shareData) else {
            print("No share found to stop")
            return
        }
        
        // Get the persistent container for proper CloudKit deletion
        guard let persistentContainer = PersistenceController.shared.container as? NSPersistentCloudKitContainer,
              let persistentStore = context.persistentStoreCoordinator?.persistentStores.first else {
            throw CloudKitError.recordNotFound
        }
        
        do {
            // Use NSPersistentCloudKitContainer to properly delete the share
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                persistentContainer.persistUpdatedShare(share, in: persistentStore) { (updatedShare, error) in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    // Update local properties
                    context.perform {
                        routine.isShared = false
                        routine.cloudKitShareData = nil
                        routine.lastModified = Date()
                        try? context.save()
                        continuation.resume(returning: ())
                    }
                }
            }
            
            print("Successfully stopped sharing for routine: \(routine.displayName)")
            
        } catch {
            print("Failed to stop sharing: \(error)")
            throw error
        }
    }
    
    /// Leaves a shared routine
    func leaveSharedRoutine(_ routine: Routine) async throws {
        guard isCloudKitEnabled else {
            throw CloudKitError.credentialsNotAvailable
        }
        
        // TODO: Implement leaving shared routine
        print("Leaving shared routine: \(routine.displayName)")
        throw CloudKitError.sharingNotSupported
    }
    
    // MARK: - Sync Operations (Stubs)
    
    /// Syncs local changes to CloudKit
    func syncToCloud() async throws {
        guard isCloudKitEnabled else {
            throw CloudKitError.credentialsNotAvailable
        }
        
        await MainActor.run {
            syncStatus = .syncing
        }
        
        // TODO: Implement actual sync
        print("Syncing local changes to CloudKit")
        
        // Simulate sync delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            syncStatus = .available
        }
    }
    
    /// Fetches changes from CloudKit
    func fetchChanges() async throws {
        guard isCloudKitEnabled else {
            throw CloudKitError.credentialsNotAvailable
        }
        
        // TODO: Implement change fetching
        print("Fetching changes from CloudKit")
    }
    
    // MARK: - Helper Methods
    
    /// Generates a unique owner ID for the current device/user
    func getCurrentOwnerID() -> String {
        // Use device identifier as owner ID for now
        // TODO: Consider using CloudKit user record ID when available
        return UIDevice.current.identifierForVendor?.uuidString ?? "unknown-device"
    }
    
    /// Checks if a routine can be shared
    func canShare(routine: Routine) -> Bool {
        return isCloudKitEnabled && !routine.isShared
    }
    
    /// Gets sharing URL for a routine (if shared)
    func getSharingURL(for routine: Routine) -> URL? {
        guard let shareData = routine.cloudKitShareData,
              let share = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKShare.self, from: shareData) else {
            return nil
        }
        
        return share.url
    }
}

// MARK: - Convenience Extensions

extension CKShare.ParticipantAcceptanceStatus {
    var displayName: String {
        switch self {
        case .unknown: return "Unknown"
        case .pending: return "Pending"
        case .accepted: return "Accepted"
        case .removed: return "Removed"
        @unknown default: return "Unknown"
        }
    }
}

extension CKShare.ParticipantPermission {
    var displayName: String {
        switch self {
        case .unknown: return "Unknown"
        case .none: return "None"
        case .readOnly: return "View Only"
        case .readWrite: return "Edit"
        @unknown default: return "Unknown"
        }
    }
}
