//
//  Persistence.swift
//  Routinier
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let entity = NSEntityDescription.entity(forEntityName: "Routine", in: viewContext)!
            let newRoutine = Routine(entity: entity, insertInto: viewContext)
            newRoutine.id = UUID()
            newRoutine.name = "Sample"
            newRoutine.recurrenceType = "interval"
            newRoutine.recurrenceValue = 4
            newRoutine.firstDueDate = Date()
            newRoutine.createdAt = Date()
            newRoutine.hour = 8
            newRoutine.minute = 0
            newRoutine.nextDueDate = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Routinier")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
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
                print("Core Data load error: \(error.localizedDescription)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
