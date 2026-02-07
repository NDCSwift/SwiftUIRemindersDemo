// MARK: - ReminderManager
// Wraps EventKit's EKEventStore to request access and perform CRUD on reminders.

import EventKit
import Observation

// Observable and main-actor confined to keep UI updates consistent and thread-safe.
@Observable
@MainActor

class ReminderManager {
    
    // Underlying EventKit store used for all reminder operations.
    private let eventStore = EKEventStore()
    
    // Cached reminders fetched from EventKit, sorted for display.
    var reminders: [EKReminder] = []
    // Current authorization state for Reminders.
    var authorizationStatus: EKAuthorizationStatus = .notDetermined
    // Last error message to surface to the UI (if any).
    var errorMessage: String?
    // Indicates active network/store work so the UI can show a spinner.
    var isLoading = false
    
    // Exposes the store for read-only access (if needed by views/components).
    var eventStoreAccess: EKEventStore { eventStore }
    
    
    // Requests full access to Reminders. On success, stores status and preloads data.
    func requestAccess() async {
        // iOS 17+: Asynchronously requests full access to Reminders.
        do{
            let granted = try await eventStore.requestFullAccessToReminders()
            
            if granted {
                authorizationStatus = .fullAccess
                await fetchReminders()
            } else {
                authorizationStatus = .denied
                errorMessage = "Access to reminders was denied."
            }
        } catch {
            errorMessage = "Failed to request Access \(error.localizedDescription)"
        }
    }
    
    // Fetches reminders with optional filtering for completed items.
    func fetchReminders(showCompleted: Bool = false) async {
        isLoading = true
        
        // Build an EventKit predicate based on the filter choice.
        let predicate: NSPredicate
        
        if showCompleted {
            predicate = eventStore.predicateForReminders(in: nil)
        } else {
            predicate = eventStore.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: nil)
        }
        // Bridge EventKit's callback API into async/await using a continuation.
        let fetchedReminders: [EKReminder] = await withCheckedContinuation { continuation in
            eventStore.fetchReminders(matching: predicate) { reminders in
                continuation.resume(returning: reminders ?? [])
                
            }
        }
        
        // Sort by due date (earliest first), falling back to title for items without dates.
        reminders = fetchedReminders.sorted { first, second in
            let firstDate = first.dueDateComponents?.date
            let secondDate = second.dueDateComponents?.date
            
            
            switch(firstDate, secondDate){
            case let (a?, b?):
                return a < b
                
            case (_?, nil):
                return true
            case(nil, _?):
                return false
            case (nil, nil):
                return first.title ?? "" < second.title ?? ""
                
                
            }
        }
        
        isLoading = false
        
    }
    
    // Creates and saves a new reminder, then refreshes the local cache.
    func createReminder(
        title: String,
        dueDate: Date? = nil,
        priority: Int = 0,
        notes: String? = nil
    ) async -> Bool {
        
        let newReminder = EKReminder(eventStore: eventStore)
        
        newReminder.title = title
        newReminder.notes = notes
        
        // Save to the user's default Reminders list.
        newReminder.calendar = eventStore.defaultCalendarForNewReminders()
        
        // Persist due date as date components (year, month, day, hour, minute).
        if let dueDate {
            newReminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        }
        
        newReminder.priority = priority
        
        do {
            try eventStore.save(newReminder, commit: true)
            await fetchReminders()
            return true
        } catch {
            errorMessage = "Failed to save reminders \(error.localizedDescription)"
            return false
        }
    }
    
    // Flips the completion state and persists the change.
    func toggleComplete(_ reminder: EKReminder) async -> Bool {
        reminder.isCompleted = !reminder.isCompleted
        
        // Persist change and then reload the list to reflect updated state.
        do {
            try eventStore.save(reminder, commit: true)
            await fetchReminders()
            return true
        }
        catch {
            errorMessage = "Failed to update reminder\(error.localizedDescription)"
            return false
        }
    }
    
    // Deletes a reminder and refreshes the cache.
    func deleteReminder(_ reminder: EKReminder) async -> Bool {
        
        do {
            try eventStore.remove(reminder, commit: true)
            
            await fetchReminders()
            return true
        } catch {
            errorMessage = "Failed to delete reminder \(error.localizedDescription)"
            return false
        }
    }
    
    // Reads the current system authorization for Reminders.
    func checkAuthorizationStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .reminder)
    }
    
}

