//
//  CompletionModal.swift
//  Routinier
//

import SwiftUI

// MARK: - Completion Modal
struct CompletionModal: View {
    @Environment(\.managedObjectContext) private var viewContext
    var routine: Routine
    @Binding var isPresented: Bool

    @State private var recurrenceValue: Int32 = 4

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Completed Routine")) {
                    Text(routine.name)
                        .font(.headline)
                    Text("Completed at: \(Date(), formatter: dateFormatter)")
                }
                Section(header: Text("Adjust Recurrence")) {
                    Stepper(value: $recurrenceValue, in: 1...60) {
                        Text("Every \(recurrenceValue) days")
                    }
                }
            }
            .navigationTitle("Routine Done")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        routine.recurrenceValue = recurrenceValue
                        routine.markCompleted()
                        try? viewContext.save()
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .onAppear {
                recurrenceValue = routine.recurrenceValue
            }
        }
    }
}
