// MARK: - ReminderCardView
// Compact card-style presentation of a single reminder with quick actions.

import SwiftUI
import EventKit

// Displays a reminder and exposes callbacks for completion toggling and deletion.
struct ReminderCardView: View {
    // The EventKit reminder to display.
    let reminder: EKReminder
    
    // Callback invoked when the user taps the complete/incomplete button.
    var onToggleComplete: () -> Void
    
    // Callback invoked when the user deletes the reminder.
    var onDelete: () -> Void
    
    // Derive a display-friendly priority from the EventKit numeric priority.
    private var priority: ReminderPriority {
        ReminderPriority(rawPriority: reminder.priority)
    }
    var body: some View {
        
        HStack(spacing: 14) {
            // Leading control to toggle completion state.
            Button {
                onToggleComplete()
            } label: {
                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(reminder.isCompleted ? .green : .secondary)
                    .animation(.easeInOut(duration: 0.2), value: reminder.isCompleted)
            }
            .buttonStyle(.plain)
            VStack{
                Text(reminder.title ?? "Untitled")
                    .font(.body)
                    .fontWeight(.medium)
                    .strikethrough(reminder.isCompleted, color: .secondary)
                    .foregroundStyle(reminder.isCompleted ? .secondary : .primary)
                
                // Show due date if present; highlight overdue items in red.
                if let dueCompenents = reminder.dueDateComponents, let dueDate = Calendar.current.date(from: dueCompenents) {
                    Text(dueDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(dueDate < Date() && !reminder.isCompleted ? .red : .secondary)
                }
                // Show a single-line preview of notes if available.
                if let notes = reminder.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Display a labeled capsule when a non-none priority is set.
            if priority != .none {
                Label(priority.label, systemImage: priority.icon)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(priority.color, in: Capsule())
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.background)
                .shadow(color: .black.opacity(0.06), radius: 4, y:2)
        ) // Card styling with subtle shadow.
        .padding(.horizontal)
        
        
    }
}

