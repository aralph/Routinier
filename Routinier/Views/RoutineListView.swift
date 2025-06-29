//
//  RoutineListView.swift
//  Routinier
//

import SwiftUI

// MARK: - Routine List View
struct RoutineListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var notificationRouter: NotificationRouter
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Routine.nextDueDate, ascending: true)],
        animation: .default)
    private var routines: FetchedResults<Routine>

    @State private var showingAddRoutine = false
    @State private var selectedRoutine: Routine? = nil
    @State private var showingCompletionModal = false
    @State private var showingEditRoutine = false
    @State private var routineToOpen: Routine? = nil

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
                            selectedRoutine = routine
                            showingCompletionModal = true
                        }) {
                            Image(systemName: "checkmark.circle")
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Edit") {
                            selectedRoutine = routine
                            showingEditRoutine = true
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            withAnimation {
                                NotificationService.shared.cancelNotification(for: routine)
                                viewContext.delete(routine)
                                try? viewContext.save()
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
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
            .sheet(isPresented: $showingCompletionModal) {
                if let routine = selectedRoutine {
                    CompletionModal(routine: routine, isPresented: $showingCompletionModal)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            .sheet(isPresented: $showingEditRoutine) {
                if let routine = selectedRoutine {
                    EditRoutineView(routine: routine)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            .onChange(of: notificationRouter.selectedRoutineID) { newID in
                if let id = newID, let match = routines.first(where: { $0.id == id }) {
                    routineToOpen = match
                }
            }
            .sheet(item: $routineToOpen) { routine in
                RoutineDetailView(routine: routine)
            }
        }
    }
}
