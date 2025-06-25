# Routine Tracking iPhone App - Project Specification (v1)

---

## 1. Purpose and Scope

The app is designed to help users build and maintain life routines by creating, tracking, and completing recurring tasks. It emphasizes behavioral reinforcement (e.g., gamification), clarity (e.g., next due dates), and optional sharing (in later versions).

---

## 2. Version Breakdown

### Version 1: Solo Local Use

* Create a routine with a name, recurrence interval, and category.
* Mark a routine as complete to reset the interval.
* Notifications/reminders when a routine is due or overdue.
* Track and visualize completion rate (e.g., % completed on time, streaks).
* All data stored locally (CoreData or SQLite).

### Version 2: Shared and Synced Use

* User accounts (sign up, log in).
* Share routines across multiple users.
* Cloud sync across devices using a FastAPI backend with PostgreSQL.

---

## 3. App Functionality (v1)

### 3.1 Core Features

* **Routine creation:**

  * Task name
  * Description (optional)
  * Recurrence logic:

    * Fixed interval (e.g., every 4 days)
    * Fixed calendar day (e.g., every 30th of month)
  * Category (e.g., Health, Home, Finance)
  * Optional first due date

* **Routine completion:**

  * User marks task done
  * Next due date is auto-calculated based on recurrence rule

* **Reminders:**

  * iOS push notifications via UNNotification framework
  * Configurable reminder timing (e.g., morning of due date)

* **Statistics/Gamification:**

  * Track how often user completes routines on time
  * Display completion streaks and rate

---

## 4. Tech Stack

### Frontend (iOS App)

* Language: Swift + SwiftUI (modern, declarative, native UI)
* Data Storage: CoreData (Apple's native local persistence)
* Notifications: UserNotifications Framework

### Backend (v2)

* Web Framework: FastAPI (Python, async, OpenAPI support)
* Hosting: Render, Railway, or custom Docker deployment
* Database: PostgreSQL
* Authentication: OAuth2 with JWT (via FastAPI's `security` module)
* API Layer: RESTful endpoints for syncing routines and completion states

---

## 5. Naming

**App Name:** Routinier

* Rationale: Unique, professional, evokes discipline and structure

---

## 6. Next Steps

1. Confirm naming and core feature list for v1.
2. Design simple UI wireframes.
3. Choose Swift project structure (MVC or MVVM).
4. Set up Xcode project and CoreData schema.
5. Build and test core functionality (create -> complete -> schedule -> notify).
6. Plan and scaffold FastAPI backend (for v2).

---

## 7. Potential Challenges

* Handling timezone edge cases in recurrence.
* Avoiding notification overload or battery drain.
* Efficiently storing and querying completion history.
* Building secure and performant FastAPI endpoints.

---

## 8. Long-Term Vision

* Habit streak tracking and rewards
* Shared routines with partner/roommate
* AI recommendations: "You usually forget X. Add it as a routine?"
* Siri/Shortcuts integration
