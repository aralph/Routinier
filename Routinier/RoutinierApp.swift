//
//  RoutinierApp.swift
//  Routinier
//

import SwiftUI

@main
struct RoutinierApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
