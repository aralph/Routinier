//
//  RoutineDetailView.swift
//  Routinier
//

import SwiftUI
import CloudKit

struct RoutineDetailView: View {
    let routine: Routine
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var cloudKitManager = CloudKitManager.shared
    @State private var showingShareSheet = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text(routine.displayName)
                .font(.largeTitle)
            
            if let description = routine.descriptionText, !description.isEmpty {
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let nextDueDate = routine.nextDueDate {
                Text("Due: \(nextDueDate, formatter: dateFormatter)")
                    .font(.title2)
            } else {
                Text("Due date not set")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            // Sharing status section
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: routine.sharingStatusIcon)
                        .foregroundColor(routine.isShared ? .blue : .gray)
                    Text(routine.sharingStatusText)
                        .foregroundColor(routine.isShared ? .blue : .gray)
                }
                
                if routine.isShared && !routine.isOwnedByCurrentUser {
                    Text("Shared by another user")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    if routine.canBeShared {
                        Button("Share Routine", action: shareRoutine)
                    }
                    
                    if routine.isShared && routine.isOwnedByCurrentUser {
                        Button("Stop Sharing", role: .destructive, action: stopSharing)
                    }
                    
                    if routine.isShared && !routine.isOwnedByCurrentUser {
                        Button("Leave Shared Routine", role: .destructive, action: leaveSharedRoutine)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(routine: routine)
        }
        .alert("Sharing Status", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Sharing Actions
    
    private func shareRoutine() {
        guard cloudKitManager.isCloudKitEnabled else {
            alertMessage = "CloudKit is not available. Please check your iCloud settings."
            showingAlert = true
            return
        }
        
        // If already shared, check if we have a valid share URL
        if routine.isShared {
            if routine.shareURL != nil {
                showingShareSheet = true
            } else {
                alertMessage = "Share not ready yet, please try again in a moment."
                showingAlert = true
            }
            return
        }
        
        // Create new share
        Task {
            do {
                // First ensure the routine is saved and synced to CloudKit
                routine.prepareForSharing()
                try viewContext.save()
                
                // Wait a moment for Core Data to sync to CloudKit
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                
                let _ = try await cloudKitManager.createShare(for: routine)
                
                await MainActor.run {
                    if routine.shareURL != nil {
                        showingShareSheet = true
                    } else {
                        alertMessage = "Failed to create share URL. Please try again."
                        showingAlert = true
                    }
                }
            } catch let error as NSError {
                await MainActor.run {
                    let errorCode = error.code
                    let errorDomain = error.domain
                    
                    var userFriendlyMessage = "Failed to create share"
                    
                    if errorDomain == "NSCocoaErrorDomain" && errorCode == 134422 {
                        userFriendlyMessage = "The routine needs to sync to iCloud first. Please try again in a moment."
                    } else {
                        userFriendlyMessage = "Failed to create share: \(error.localizedDescription)"
                    }
                    
                    alertMessage = userFriendlyMessage
                    showingAlert = true
                }
            }
        }
    }
    
    private func stopSharing() {
        Task {
            do {
                try await cloudKitManager.stopSharing(routine: routine)
                
                await MainActor.run {
                    do {
                        try viewContext.save()
                        alertMessage = "Stopped sharing this routine."
                        showingAlert = true
                    } catch {
                        alertMessage = "Failed to stop sharing: \(error.localizedDescription)"
                        showingAlert = true
                    }
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Failed to stop sharing: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
    
    private func leaveSharedRoutine() {
        Task {
            do {
                try await cloudKitManager.leaveSharedRoutine(routine)
                
                await MainActor.run {
                    // Remove from local storage
                    viewContext.delete(routine)
                    
                    do {
                        try viewContext.save()
                    } catch {
                        alertMessage = "Failed to leave shared routine: \(error.localizedDescription)"
                        showingAlert = true
                    }
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Failed to leave shared routine: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let routine: Routine
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let items: [Any] = [
            "Join my routine: \(routine.displayName)",
            routine.shareURL! // Safe to force unwrap - we checked this before showing the sheet
        ]
        
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.completionWithItemsHandler = { _, _, _, _ in
            dismiss()
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}
