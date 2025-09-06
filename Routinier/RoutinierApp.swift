//
//  RoutinierApp.swift
//  Routinier
//

import SwiftUI
import CloudKit

@main
struct RoutinierApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared

    @StateObject private var notificationRouter = NotificationRouter()
    @State private var showingSharingAlert = false
    @State private var sharingAlertMessage = ""

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
                .onOpenURL { url in
                    handleIncomingURL(url)
                }
                .alert("Sharing", isPresented: $showingSharingAlert) {
                    Button("OK") { }
                } message: {
                    Text(sharingAlertMessage)
                }
        }
    }
    
    // MARK: - URL Handling
    
    private func handleIncomingURL(_ url: URL) {
        print("Received URL: \(url)")
        
        // Check if this is a CloudKit share URL
        if url.absoluteString.contains("icloud.com/share") {
            handleCloudKitShareURL(url)
        }
    }
    
    private func handleCloudKitShareURL(_ url: URL) {
        print("Processing CloudKit share URL: \(url)")
        
        // Fetch share metadata from the URL
        let operation = CKFetchShareMetadataOperation(shareURLs: [url])
        
        operation.fetchShareMetadataCompletionBlock = { error in
            if let error = error {
                print("Failed to fetch share metadata: \(error)")
                return
            }
            print("Share metadata fetch completed")
        }
        
        operation.perShareMetadataBlock = { url, metadata, error in
            Task { @MainActor in
                if let error = error {
                    print("Error fetching metadata for \(url): \(error)")
                    return
                }
                
                guard let metadata = metadata else {
                    print("No metadata found for share URL")
                    return
                }
                
                // Accept the share invitation
                do {
                    try await CloudKitManager.shared.acceptShare(with: metadata)
                    print("Successfully accepted share invitation")
                    sharingAlertMessage = "Successfully joined shared routine!"
                    showingSharingAlert = true
                } catch {
                    print("Failed to accept share: \(error)")
                    sharingAlertMessage = "Failed to join shared routine: \(error.localizedDescription)"
                    showingSharingAlert = true
                }
            }
        }
        
        CKContainer(identifier: "iCloud.com.aralph.Routinier").add(operation)
    }
}
