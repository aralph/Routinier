//
//  PreviewData.swift
//  Routinier
//
// Only included in debug builds

#if DEBUG
import CoreData

extension PersistenceController {
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        for i in 0..<10 {
            let routine = Routine(context: context)
            routine.id = UUID()
            routine.name = "Routine #\(i + 1)"
            routine.descriptionText = "Description for routine #\(i + 1)"
            routine.recurrenceType = "interval"
            routine.recurrenceValue = 4
            routine.firstDueDate = Date()
            routine.createdAt = Date()
            routine.nextDueDate = Calendar.current.date(byAdding: .day, value: 4, to: Date()) ?? Date()
            routine.hour = 9
            routine.minute = 0
        }

        do {
            try context.save()
        } catch {
            fatalError("Failed to save preview data: \(error)")
        }

        return controller
    }()
}
#endif
