//
//  AddRoutineView.swift
//  Routinier
//

import SwiftUI

// MARK: - Add Routine View
struct AddRoutineView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var descriptionText: String = ""
    @State private var recurrenceType: String = "interval"
    @State private var recurrenceValue: Int = 4
    @State private var firstDueDate: Date = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Routine Info")) {
                    TextField("Name", text: $name)
                    TextField("Description", text: $descriptionText)
                }
                Section(header: Text("Recurrence")) {
                    Picker("Type", selection: $recurrenceType) {
                        Text("Every X days").tag("interval")
                        Text("Monthly").tag("calendar")
                    }
                    Stepper(value: $recurrenceValue, in: 1...31) {
                        Text("Every \(recurrenceValue) days")
                    }
                    DatePicker("First Due Date", selection: $firstDueDate, displayedComponents: .date)
                }
            }
            .navigationTitle("New Routine")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newRoutine = Routine(context: viewContext)
                        newRoutine.id = UUID()
                        newRoutine.name = name
                        newRoutine.descriptionText = descriptionText
                        newRoutine.recurrenceType = recurrenceType
                        newRoutine.recurrenceValue = Int32(recurrenceValue)
                        newRoutine.firstDueDate = firstDueDate
                        newRoutine.createdAt = Date()
                        newRoutine.nextDueDate = firstDueDate
                        try? viewContext.save()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
