//
//  EditRoutineView.swift
//  Routinier
//

import SwiftUI

// MARK: - Edit Routine View
struct EditRoutineView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var routine: Routine

    @State private var name: String = ""
    @State private var descriptionText: String = ""
    @State private var recurrenceType: String = "interval"
    @State private var recurrenceValue: Int = 4
    @State private var firstDueDate: Date = Date()
    @State private var timeOfDay: Date = Calendar.current.date(from: DateComponents(hour: 20, minute: 0))!

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
                        Text("Weekly").tag("weekly")
                        Text("Monthly").tag("monthly")
                        Text("Yearly").tag("yearly")
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    if recurrenceType == "interval" {
                        Stepper(value: $recurrenceValue, in: 1...31) {
                            Text("Every \(recurrenceValue) days")
                        }
                    }
                    DatePicker("First Due Date", selection: $firstDueDate, displayedComponents: .date)
                    DatePicker("Time of Day", selection: $timeOfDay, displayedComponents: .hourAndMinute)
                }
            }
            .navigationTitle("Edit Routine")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        routine.name = name
                        routine.descriptionText = descriptionText
                        routine.recurrenceType = recurrenceType
                        routine.recurrenceValue = Int32(recurrenceValue)
                        routine.firstDueDate = firstDueDate

                        let calendar = Calendar.current
                        let dateParts = calendar.dateComponents([.hour, .minute], from: timeOfDay)
                        routine.hour = Int16(dateParts.hour ?? 0)
                        routine.minute = Int16(dateParts.minute ?? 0)

                        try? viewContext.save()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                name = routine.name
                descriptionText = routine.descriptionText ?? ""
                recurrenceType = routine.recurrenceType
                recurrenceValue = Int(routine.recurrenceValue)
                firstDueDate = routine.firstDueDate ?? Date()

                let hour = Int(routine.hour)
                let minute = Int(routine.minute)
                timeOfDay = Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? timeOfDay
            }
        }
    }
}
