# Routinier UI Design - Wireframe Drafts (v1)

---

## 1. App Navigation Structure

**Tab Bar (Bottom Navigation)**

* **Routines** (main screen)
* **Stats** (gamification overview)
* **Settings**

---

## 2. Screens and Layouts

### 2.1 Routines Screen

**Purpose:** Display all active routines sorted by due date.

**UI Elements:**

* Top: Title bar ("My Routines")
* List of routines:

  * [ ] Checkbox (to mark as done)
  * Task name (e.g., "Water plants")
  * Next due date (e.g., "Due in 2 days")
  * Optional category icon (e.g., leaf for plants)
* Floating "+" button for new routine

### 2.2 Add/Edit Routine Screen

**Purpose:** Create or modify a routine.

**UI Elements:**

* Text input: Routine name
* Text input: Optional description
* Picker: Recurrence rule

  * Every X days (number input)
  * Monthly on day X
* Picker: Category (icon grid or dropdown)
* Date picker: First due date (optional)
* Save button (top-right or bottom)

### 2.3 Completion Confirmation Modal

**Purpose:** Confirm and provide feedback when marking routine as done.

**UI Elements:**

* Message: "Routine completed!"
* Icon/animation (confetti, checkmark)
* Button: "OK"
* Button: "Adjust recurrence" (opens Edit Routine screen)

### 2.4 Stats Screen

**Purpose:** Visualize routine adherence.

**UI Elements:**

* Streak display (e.g., "5 routines completed in a row")
* Completion rate per routine (% on time)
* Weekly chart (bar or heatmap)

### 2.5 Settings Screen

**Purpose:** Manage notification times, theme, and data reset.

**UI Elements:**

* Notification time (e.g., 9:00 AM)
* Toggle: Enable/disable reminders
* Button: Export data (v2)
* Button: Reset all routines

---

## 3. Design Notes

* SwiftUI-native components only (List, DatePicker, Picker, Toggle, etc.)
* Prioritize minimalism and accessibility
* Light and dark mode support from the start

---

## 4. Next Steps

* Confirm tab layout and routine creation flow
* Translate wireframes into SwiftUI View files
* Connect views to CoreData model (next step)

