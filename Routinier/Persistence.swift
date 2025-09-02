//
//  Persistence.swift
//  Routinier
//

import CoreData
import CloudKit

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer
    private let cloudKitManager = CloudKitManager.shared

    init(inMemory: Bool = false) {
        let localContainer = NSPersistentContainer(name: "Routinier")
        
        // Configure CloudKit integration when credentials are available
        if !inMemory && cloudKitManager.isCloudKitEnabled {
            configureCloudKitStore(for: localContainer)
        }

        if inMemory {
            localContainer.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        localContainer.loadPersistentStores { description, error in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                print("Core Data load error: \(error), \(error.userInfo)")
            } else {
                print("Store loaded: \(description)")
                print("Entities: \(localContainer.managedObjectModel.entitiesByName.keys)")
            }
        }
        localContainer.viewContext.automaticallyMergesChangesFromParent = true
        self.container = localContainer
    }
    
    // MARK: - CloudKit Configuration
    
    /// Configures CloudKit store (stub implementation)
    private func configureCloudKitStore(for container: NSPersistentContainer) {
        // TODO: Enable when CloudKit credentials are available
        // This would configure NSPersistentCloudKitContainer instead of NSPersistentContainer
        print("CloudKit store configuration ready (awaiting credentials)")
        
        /* Future implementation:
        guard let storeDescription = container.persistentStoreDescriptions.first else { return }
        
        storeDescription.setOption(true as NSNumber, 
                                 forKey: NSPersistentHistoryTrackingKey)
        storeDescription.setOption(true as NSNumber, 
                                 forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        // Configure CloudKit container options
        let containerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.com.yourname.Routinier"
        )
        storeDescription.cloudKitContainerOptions = containerOptions
        */
    }
    
    // MARK: - Sync Operations
    
    /// Triggers sync with CloudKit (when available)
    func syncWithCloudKit() async {
        guard cloudKitManager.isCloudKitEnabled else {
            print("CloudKit not available, skipping sync")
            return
        }
        
        do {
            try await cloudKitManager.syncToCloud()
            print("CloudKit sync completed")
        } catch {
            print("CloudKit sync failed: \(error)")
        }
    }
    
    /// Saves context and optionally syncs to CloudKit
    func save(syncToCloud: Bool = false) {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
                print("Core Data context saved")
                
                if syncToCloud {
                    Task {
                        await syncWithCloudKit()
                    }
                }
            } catch {
                print("Core Data save error: \(error)")
            }
        }
    }
}
