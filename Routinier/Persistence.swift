//
//  Persistence.swift
//  Routinier
//

import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        let localContainer = NSPersistentContainer(name: "Routinier")

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
}
