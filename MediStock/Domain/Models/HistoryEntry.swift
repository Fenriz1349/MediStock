//
//  HistoryEntry.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import Foundation

/// A single audit-trail record of a change made to a medicine's stock or details.
struct HistoryEntry: Identifiable, Codable, Equatable {
    var id: String? = nil
    var medicineId: String
    var user: String
    var action: String
    var details: String
    var timestamp: Date = Date()
}
