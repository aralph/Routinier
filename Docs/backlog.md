# Routinier v1 – Feature Backlog

This document tracks planned features for version 1 of the Routinier app.

## ✅ Implemented
- Create routines with flexible recurrence (interval, weekly, monthly, yearly)
- Core Data persistence with preview/testing support
- SwiftUI interface for listing, creating, and completing routines
- Statistics and Settings placeholder screens
- Basic model validation tests

## 🔜 Planned

### 1. Completion Modal
- Show confirmation screen after user marks routine as done
- Allow editing of recurrence rule inline
- Optionally set manual completion timestamp

### 2. Fulfillment Stats
- Track completion history
- Calculate fulfillment rate and missed sessions
- Visual feedback (e.g. progress bars, streaks)

### 3. Notification Scheduling
- Use local notifications for reminders
- Schedule next due date alerts
- Handle app permission prompts gracefully

### 4. Routine Editing
- Ability to edit existing routines
- Update recurrence rule or due dates
- Confirmation before deletion

### 5. Shared Routines (for v2+)
- Cloud sync support (FastAPI backend)
- Multi-user sharing of routines
- Authentication and account management

## 🧪 Testing and Developer Tools
- More model and logic unit tests
- UI preview mock data consistency
- Improved Core Data error reporting/logging
