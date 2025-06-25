//
//  MainTabView.swift
//  Routinier
//

// SwiftUI Views for Routinier (v1)
// Core UI for viewing, adding, and completing routines

import SwiftUI
//import CoreData

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

// MARK: - Placeholder Views
struct StatsView: View {
    var body: some View {
        Text("Stats Coming Soon")
    }
}

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
