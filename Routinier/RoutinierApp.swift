//
//  RoutinierApp.swift
//  Routinier
//

import SwiftUI

@main
struct RoutinierApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared

    @StateObject private var notificationRouter = NotificationRouter()

    init() {
        AppDelegate.notificationRouter = notificationRouter
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(notificationRouter)
                .onAppear {
                    NotificationService.shared.requestPermission()
                }
        }
    }
}
