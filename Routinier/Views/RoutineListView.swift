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

    enum ActiveSheet: Identifiable {
        case add, complete(Routine), edit(Routine), detail(Routine)

        var id: String {
            switch self {
            case .add: return "add"
            case .complete(let r): return "complete_\(r.id)"
            case .edit(let r): return "edit_\(r.id)"
            case .detail(let r): return "detail_\(r.id)"
            }
        }
    }

    @State private var activeSheet: ActiveSheet?

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
                            activeSheet = .complete(routine)
                        }) {
                            Image(systemName: "checkmark.circle")
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Edit") {
                            activeSheet = .edit(routine)
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
                Button(action: { activeSheet = .add }) {
                    Label("Add Routine", systemImage: "plus")
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .add:
                    AddRoutineView()
                        .environment(\.managedObjectContext, viewContext)
                case .complete(let routine):
                    CompletionModal(routine: routine, isPresented: Binding(
                        get: { activeSheet != nil },
                        set: { if !$0 { activeSheet = nil } }
                    ))
                    .environment(\.managedObjectContext, viewContext)
                case .edit(let routine):
                    EditRoutineView(routine: routine)
                        .environment(\.managedObjectContext, viewContext)
                case .detail(let routine):
                    RoutineDetailView(routine: routine)
                }
            }
            .onChange(of: notificationRouter.selectedRoutineID) { newID in
                if let id = newID, let match = routines.first(where: { $0.id == id }) {
                    activeSheet = .detail(match)
                }
            }
        }
    }
}
