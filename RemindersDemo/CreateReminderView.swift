// MARK: - CreateReminderView
// Form for composing and saving a new reminder via ReminderManager.

import SwiftUI

// Receives a ReminderManager instance from the parent to perform saves and report errors.
struct CreateReminderView: View {
    var reminderManager: ReminderManager
    // Used to dismiss the sheet after save or cancel.
    @Environment(\.dismiss) private var dismiss
    
    // User-entered title for the reminder (required).
    @State private var title = ""
    // Toggles whether a due date is set.
    @State private var hasDueDate = false
    // The selected due date/time (only used if hasDueDate is true).
    @State private var dueDate = Date()
    // Selected priority mapped to EventKit values.
    @State private var selectedPriority: ReminderPriority = .none
    // Optional notes text for the reminder.
    @State private var notes = ""
    // Controls display of an alert when saving fails.
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Title input
                Section("What do you need to do?") {
                    TextField ("reminder title", text: $title)
                }
                // Due date toggle and picker
                Section( "Due Date") {
                    Toggle("Set a due date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("due", selection: $dueDate,
                                   displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                // Priority selection
                Section("Priority") {
                    Picker("priority", selection: $selectedPriority) {
                        Text("None").tag(ReminderPriority.none)
                        Text("Low").tag(ReminderPriority.low)
                        Text("Medium").tag(ReminderPriority.medium)
                        Text("High").tag(ReminderPriority.high)
                    }
                    .pickerStyle(.segmented)
                }
                // Optional notes field
                Section("Notes") {
                    TextField("Add Notes (Optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                    
                }
            }
            .navigationTitle("New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { // Navigation actions for cancel/save
                // Dismiss without saving.
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                // Save the reminder using the manager; disabled if title is empty.
                ToolbarItem(placement: .topBarTrailing) {
                    Button("save") { saveReminder() }
                        .fontWeight(.semibold)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("Could Not Save reminder", isPresented: $showingError) { // Shows the manager's error message if saving fails.
                Button("OK", role: .cancel) { }
            } message: {
                Text(reminderManager.errorMessage ?? "An unknown error occured")
            }
        }
    }
    
    // Validates inputs and calls into the manager to create a reminder.
    private func saveReminder() {
        Task {
            // Trim whitespace and only include due date/notes if provided.
            let success = await reminderManager.createReminder(title: title.trimmingCharacters(in: .whitespaces),
                                                               dueDate: hasDueDate ? dueDate : nil,
                                                               priority: selectedPriority.eventKitValue,
                                                               notes: notes.isEmpty ? nil : notes
            )
            if success {
                dismiss()
            } else {
                showingError = true
            }
        }
    }
}

