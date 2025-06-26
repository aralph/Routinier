//
//  RoutinierApp.swift
//  Routinier
//

import SwiftUI

@main
struct RoutinierApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var notificationRouter = NotificationRouter()
    init() {
        AppDelegate.notificationRouter = notificationRouter
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(notificationRouter)
                .onAppear {
                    NotificationService.shared.requestPermission()
                }
        }
    }
}
