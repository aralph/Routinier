//
//  MainTabView.swift
//  Routinier
//

// SwiftUI Views for Routinier (v1)
// Core UI for viewing, adding, and completing routines

import SwiftUI
import Charts

// MARK: - Main Tab View
struct MainTabView: View {
    var body: some View {
        TabView {
            RoutineListView()
                .tabItem {
                    Label("Routines", systemImage: "list.bullet")
                }
            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear {
            NotificationService.shared.requestPermission()
        }
    }
}

// MARK: - Stats View
struct StatsView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Routine.name, ascending: true)],
        animation: .default)
    private var routines: FetchedResults<Routine>

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Routine Fulfillment")
                    .font(.title2)
                    .padding(.horizontal)

                let routineData: [(name: String, rate: Double)] = routines.map { routine in
                    (routine.name, routine.fulfillmentRate * 100)
                }

                Chart {
                    ForEach(routineData, id: \.name) { item in
                        BarMark(
                            x: .value("Routine", item.name),
                            y: .value("Fulfillment", item.rate)
                        )
                        .foregroundStyle(.blue)
                        .accessibilityLabel("\(item.name): \(Int(item.rate)) percent fulfilled")
                    }
                }
                .chartYAxisLabel("% Completed")
                .chartYScale(domain: 0...100)
                .padding()
            }
            .navigationTitle("Stats")
        }
    }
}


// MARK: - Placeholder Views
struct SettingsView: View {
    var body: some View {
        Text("Settings Coming Soon")
    }
}

// MARK: - Formatter
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

// MARK: - Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}

struct NotificationDebugView: View {
    @State private var pending = [UNNotificationRequest]()

    var body: some View {
        List(pending, id: \.identifier) { request in
            VStack(alignment: .leading) {
                Text(request.content.title).bold()
                Text(request.content.body)
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    Text("Trigger date: \(trigger.nextTriggerDate()?.description ?? "nil")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                DispatchQueue.main.async {
                    pending = requests
                }
            }
        }
        .navigationTitle("Scheduled Notifications")
    }
}
