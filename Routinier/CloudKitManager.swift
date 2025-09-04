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
    
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private let sharedDatabase: CKDatabase
    
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
        // Use your CloudKit container
        self.container = CKContainer(identifier: "iCloud.com.aralph.Routinier")
        self.privateDatabase = container.privateCloudDatabase
        self.sharedDatabase = container.sharedCloudDatabase
        
        checkCloudKitAvailability()
    }
    
    // MARK: - CloudKit Availability
    
    private func checkCloudKitAvailability() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
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
        
        guard let context = routine.managedObjectContext else {
            throw CloudKitError.recordNotFound
        }
        
        // Use NSPersistentCloudKitContainer.share() method
        return try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    guard let persistentStore = context.persistentStoreCoordinator?.persistentStores.first else {
                        continuation.resume(throwing: CloudKitError.recordNotFound)
                        return
                    }
                    
                    // Use the Core Data sharing API
                    let shareResult = try context.persistentStoreCoordinator?.share([routine], to: persistentStore)
                    
                    guard let (_, share, _) = shareResult else {
                        continuation.resume(throwing: CloudKitError.sharingNotSupported)
                        return
                    }
                    
                    // Store share data in routine
                    if let shareData = try? NSKeyedArchiver.archivedData(withRootObject: share, requiringSecureCoding: true) {
                        routine.cloudKitShareData = shareData
                        routine.isShared = true  
                        routine.lastModified = Date()
                        try? context.save()
                    }
                    
                    print("Successfully created share for routine: \(routine.displayName)")
                    continuation.resume(returning: share)
                    
                } catch {
                    print("Failed to create share: \(error)")
                    continuation.resume(throwing: error)
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
        
        do {
            // Delete the share from CloudKit
            try await privateDatabase.delete(withRecordID: share.recordID)
            
            // Update local properties
            await context.perform {
                routine.isShared = false
                routine.cloudKitShareData = nil
                routine.lastModified = Date()
                try? context.save()
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
        print("Leaving shared routine: \(routine.name)")
        throw CloudKitError.sharingNotSupported
    }
    
    // MARK: - Sync Operations (Stubs)
    
    /// Syncs local changes to CloudKit
    func syncToCloud() async throws {
        guard isCloudKitEnabled else {
            throw CloudKitError.credentialsNotAvailable
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.syncStatus = .syncing
        }
        
        // TODO: Implement actual sync
        print("Syncing local changes to CloudKit")
        
        // Simulate sync delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        DispatchQueue.main.async { [weak self] in
            self?.syncStatus = .available
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