//
//  Project: RemindersDemo
//  File: ReminderPriority.swift
//  Created by Noah Carpenter 
//
//  📺 YouTube: Noah Does Coding
//  https://www.youtube.com/@NoahDoesCoding97
//  Like and Subscribe for coding tutorials and fun! 💻✨
//  Dream Big. Code Bigger 🚀
//

// MARK: - ReminderPriority
// Small helper to translate EventKit priority integers to UI-friendly values.

import SwiftUI

// Encapsulates mapping between EventKit's 1-9 priority scale and app semantics.
enum ReminderPriority {
    
    case high       // Priority 1-4 in EventKit
    case medium     // Priority 5 in EventKit
    case low        // Priority 6-9 in EventKit
    case none       // Priority 0 in EventKit
    
    // Create from EventKit's numeric priority.
    init(rawPriority: Int) {
        switch rawPriority {
        case 1...4: self = .high
        case 5: self = .medium
        case 6...9: self = .low
        default: self = .none
        }
    }
    
    // Visual color to represent the priority.
    var color: Color {
        switch self {
        case .high: return  .red
        case .medium: return .orange
        case .low: return .yellow
        case .none: return .clear
        }
    }
    
    // Short text label for display.
    var label: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        case .none: return ""
        }
    }
    
    // SF Symbols icon name matching intensity.
    var icon: String {
        switch self {
        case .high: return "exclamationmark.3"
        case .medium: return "exclamationmark.2"
        case .low: return "exclamationmark"
        case .none: return ""
        }
    }
    
    // Convert back to EventKit's priority integer for saving.
    var eventKitValue: Int {
        switch self {
        case .high: return 1
        case .medium: return 5
        case .low: return 9
        case .none: return 0
        }
    }
    
}
