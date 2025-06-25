# Routinier - Local Development Setup Guide (SwiftUI + CoreData)

---

## 1. Prerequisites

* macOS with latest Xcode installed (15.x+ recommended)
* iPhone device or simulator
* Git and GitHub account

---

## 2. Project Bootstrapping

### Option A: Manual Setup

1. Open Xcode → New Project → iOS → App
2. Product Name: `Routinier`
3. Interface: SwiftUI
4. Language: Swift
5. Use CoreData: ✅ Enabled

This creates a working SwiftUI + CoreData template.

### Option B: Clone Existing Repo

If you've pushed the code from Canvas into a GitHub repository:

1. On your laptop: `git clone https://github.com/YOUR_USERNAME/routinier.git`
2. Open `Routinier.xcodeproj` in Xcode

If you haven’t pushed it yet, follow section 4 below.

---

## 3. Add Canvas Code to Your Local Project

For each Canvas document:

* `Routine Coredata Model.swift` → Add to `Model` group in Xcode
* `Routine Swiftui Views.swift` → Add to `Views` group in Xcode
* Manually copy/paste into respective Swift files
* Be sure to register `Routine` and `Completion` entities in your `.xcdatamodeld` file

Use Xcode → Editor → Add Entity for that, with attributes and relationships.

---

## 4. (Optional) Push to GitHub

1. Create GitHub repo: `routinier`
2. In terminal:

   ```bash
   cd /path/to/project
   git init
   git remote add origin https://github.com/YOUR_USERNAME/routinier.git
   git add .
   git commit -m "Initial commit"
   git push -u origin main
   ```

---

## 5. Run & Debug

* Choose an iOS simulator or physical iPhone (plugged in)
* Press ▶ in Xcode
* Debug live updates with `@State`, `@Environment`, `@FetchRequest`

---

## 6. Coming Next

* Enable notifications via `UNUserNotificationCenter`
* Build the stats view with charts
* Extend Add/Edit screen for recurrence flexibility

Let me know if you want a `.xcdatamodeld` layout draft or help creating the GitHub repo.
