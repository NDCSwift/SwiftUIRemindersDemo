# ✅ Reminders — EventKit + SwiftUI Demo

A SwiftUI demo showing how to create, read, and manage iOS Reminders using the EventKit framework — with priority support, a creation sheet, and card-based list UI.

---

## 🤔 What this is

This project integrates with the native iOS Reminders app via `EventKit`. It shows how to request calendar/reminders access, fetch existing reminders, create new ones with titles, due dates, and priority levels, and mark them complete — all from a SwiftUI interface with a `ReminderManager` observable class driving the state.

## ✅ Why you'd use it

- **Full EventKit Reminders workflow** — authorization, fetch, create, and complete in one example
- **Priority system** — `ReminderPriority.swift` maps EventKit's priority integers to a readable enum
- **Card-based UI** — `ReminderCardView` is a polished, reusable list item you can adapt immediately
- **`@Observable` pattern** — `ReminderManager` uses Swift 5.9 observation, not legacy `ObservableObject`

## 📺 Watch on YouTube

[![Watch on YouTube](https://img.shields.io/badge/YouTube-Watch%20the%20Tutorial-red?style=for-the-badge&logo=youtube)](https://youtu.be/T5ftEqlVGC0)

> This project was built for the [NoahDoesCoding YouTube channel](https://www.youtube.com/@NoahDoesCoding97). Subscribe for weekly SwiftUI tutorials.

---

## 🚀 Getting Started

### 1. Clone the Repo
```bash
git clone https://github.com/NDCSwift/SwiftUIRemindersDemo.git
cd SwiftUIRemindersDemo
```

### 2. Open in Xcode
Double-click `RemindersDemo.xcodeproj`.

### 3. Set Your Development Team
**TARGET → Signing & Capabilities → Team**

### 4. Update the Bundle Identifier
Change `com.example.MyApp` to a unique identifier.

### 5. Run
Reminders access requires accepting the permission prompt on first launch.

---

## 🛠️ Notes

- Add `NSRemindersUsageDescription` to `Info.plist`
- EventKit access must be requested at runtime — the app will prompt automatically
- If you see a code signing error, check that Team and Bundle ID are set

## 📦 Requirements

- Xcode 15+
- iOS 17+
- No third-party dependencies

📺 [Watch the guide on YouTube](https://youtu.be/T5ftEqlVGC0)
