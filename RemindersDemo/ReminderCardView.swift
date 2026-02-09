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
        HStack(spacing: 12) {
            // Leading control to toggle completion state.
            Button {
                onToggleComplete()
            } label: {
                ZStack {
                    Circle()
                        .fill(reminder.isCompleted ? Color.green.opacity(0.15) : Color.secondary.opacity(0.12))
                        .frame(width: 30, height: 30)
                    Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(reminder.isCompleted ? .green : .secondary)
                        .animation(.easeInOut(duration: 0.2), value: reminder.isCompleted)
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title ?? "Untitled")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .strikethrough(reminder.isCompleted, color: .secondary)
                    .foregroundStyle(reminder.isCompleted ? .secondary : .primary)
                    .accessibilityLabel(reminder.title ?? "Untitled")

                HStack(spacing: 8) {
                    // Show due date if present; highlight overdue items in red.
                    if let dueCompenents = reminder.dueDateComponents, let dueDate = Calendar.current.date(from: dueCompenents) {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                            Text(dueDate, style: .date)
                        }
                        .font(.caption)
                        .foregroundStyle(dueDate < Date() && !reminder.isCompleted ? .red : .secondary)
                    }

                    // Display a small separator dot if both date and notes are visible.
                    if let notes = reminder.notes, !notes.isEmpty, reminder.dueDateComponents != nil {
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    // Show a single-line preview of notes if available.
                    if let notes = reminder.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
            }

            Spacer(minLength: 8)

            // Display a labeled capsule when a non-none priority is set.
            if priority != .none {
                Label(priority.label, systemImage: priority.icon)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(colors: [priority.color.opacity(0.95), priority.color.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: Capsule()
                    )
                    .overlay(
                        Capsule().stroke(.white.opacity(0.15), lineWidth: 1)
                    )
                    .shadow(color: priority.color.opacity(0.25), radius: 4, y: 2)
            }
        }
        .padding(16)
        .background(
            ZStack {
                // Subtle background to stand out from list background
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)
                // Soft highlight at the top-left for depth
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(colors: [Color.white.opacity(0.12), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            // Hairline border to improve contrast on both light/dark modes
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.10), radius: 8, y: 4)
        .padding(.horizontal)
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        
    }
}

