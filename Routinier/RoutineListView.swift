//
//  RoutineListView.swift
//  Routinier
//

import SwiftUI

struct RoutineListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Routine.nextDueDate, ascending: true)],
        animation: .default)
    private var routines: FetchedResults<Routine>

    @State private var showingAddRoutine = false

    var body: some View {
        NavigationView {
            List {
                ForEach(routines) { routine in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(routine.name)
                                .font(.headline)
                            Text("Due: \(routine.nextDueDate, formatter: dateFormatter)")
                                .font(.subheadline)
                        }
                        Spacer()
                        Button(action: {
                            routine.markCompleted()
                            try? viewContext.save()
                        }) {
                            Image(systemName: "checkmark.circle")
                        }
                    }
                }
            }
            .navigationTitle("My Routines")
            .toolbar {
                Button(action: { showingAddRoutine.toggle() }) {
                    Label("Add Routine", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingAddRoutine) {
                AddRoutineView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
}
