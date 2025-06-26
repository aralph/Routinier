//
//  NotificationService.swift
//  Routinier
//


import Foundation
import UserNotifications
import CoreData

class NotificationService {
    static let shared = NotificationService()

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

    func scheduleNotification(for routine: Routine) {
        let id = routine.id.uuidString

        let content = UNMutableNotificationContent()
        content.title = "Routine Reminder"
        content.body = "It's time for: \(routine.name)"
        content.sound = .default

        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: routine.nextDueDate)
        dateComponents.hour = Int(routine.hour)
        dateComponents.minute = Int(routine.minute)

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }

    func cancelNotification(for routine: Routine) {
        let id = routine.id.uuidString
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}
