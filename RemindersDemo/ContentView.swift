// MARK: - Main Reminders list view
// Drives the app UI, handles permission flow, fetching, and creation of reminders.

import SwiftUI
import EventKit

struct ContentView: View {
    // Central manager that wraps EventKit access and business logic.
    @State private var reminderManager = ReminderManager()
    
    // Controls presentation of the sheet for creating a new reminder.
    @State private var showingCreateReminder = false
    
    // Toggles between showing only incomplete reminders and all (including completed).
    @State private var showCompleted = false
    var body: some View {
        // NavigationStack provides a modern navigation container for the list and detail flows.
        NavigationStack {
            Group {
                // Show the main list if we have full access; otherwise guide the user to grant permission.
                if reminderManager.authorizationStatus == .fullAccess {
                    reminderListView
                } else {
                    permissionView
                }
            }
            .navigationTitle("Reminders")
            .toolbar {
                // Leading toolbar button toggles the completed filter and refetches reminders.
                if reminderManager.authorizationStatus == .fullAccess {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showCompleted.toggle()
                            Task { await reminderManager.fetchReminders(showCompleted: showCompleted) } // Refresh list to reflect the new filter.
                        } label: {
                            Image(systemName: showCompleted ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        }
                    }
                    // Trailing toolbar button opens the sheet to create a new reminder.
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingCreateReminder = true
                        } label:
                        {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCreateReminder) { // Presents the create reminder form when `showingCreateReminder` is true.
                // Pass the same manager so the sheet can save and refresh the list.
                CreateReminderView(reminderManager: reminderManager)
            }
            .task { // Run once when the view appears to ensure authorization and load data.
                // Check current Reminders authorization before proceeding.
                reminderManager.checkAuthorizationStatus()
                // If the user hasn't been asked yet, request access.
                if reminderManager.authorizationStatus == .notDetermined {
                    await reminderManager.requestAccess()
                }
                // If already authorized, fetch reminders immediately.
                else if reminderManager.authorizationStatus == .fullAccess {
                    await reminderManager.fetchReminders(showCompleted: showCompleted)
                }
            }

        }
        .padding()
    }
    
    private var reminderListView: some View {
        Group {
            // Show a loading indicator while reminders are being fetched.
            if reminderManager.isLoading {
                ProgressView("Loading Reminders...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            // Empty state when no reminders match the current filter.
            else if reminderManager.reminders.isEmpty {
                // Message adapts based on the completed filter.
                ContentUnavailableView("No Reminders", systemImage: "checklist", description: Text(showCompleted ? "You don't have any reminders yet" : "All caught up! No imcomplete Reminders!")) 
                
            } else {
                // Scrollable list of reminder cards with lazy rendering for performance.
                ScrollView {
                    LazyVStack(spacing: 10){
                        // Use the stable EventKit identifier to uniquely identify each reminder.
                        ForEach(reminderManager.reminders, id: \.calendarItemIdentifier) {
                            reminder in
                            
                            ReminderCardView(reminder: reminder, onToggleComplete: { Task { await reminderManager.toggleComplete(reminder) }}, onDelete: { Task { await reminderManager.deleteReminder(reminder) }}) // Inline actions toggle completion and delete, both refreshing the list on completion.
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) { // Provide a destructive swipe-to-delete action for quick removal.
                                    Button(role: .destructive) {
                                        Task { await reminderManager.deleteReminder(reminder) }
                                        
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
    
    private var permissionView: some View {
        // Shown when the app doesn't have Reminders access; guides user to grant or open Settings.
        ContentUnavailableView {
            Label("Reminder access required", systemImage: "checklist.unchecked")
        } description: {
            Text("This app needs access to your reminders to display and manage tasks.")
        } actions: {
            // If access was explicitly denied, direct the user to the app's Settings page.
            if reminderManager.authorizationStatus == .denied {
                Button("Open settings"){ // Opens Settings so the user can change Reminders permissions.
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            // Otherwise, request access in-app using EventKit.
            else {
                Button("Grant Access") { // Triggers the async authorization request.
                    Task { await reminderManager.requestAccess() }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    
}

// MARK: - Preview
#Preview {
    ContentView()
}

