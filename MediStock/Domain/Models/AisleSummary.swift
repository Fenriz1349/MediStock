//
//  AisleSummary.swift
//  MediStock
//
//  Created by Julien Cotte on 16/08/2026.
//

import Foundation

/// A distinct aisle code and how many medicines are currently stored in it.
/// Read from the `aisles` collection — a query-optimization document, not a real Domain entity.
struct AisleSummary: Identifiable, Codable, Equatable, Hashable {
    var id: String { code }
    let code: String
    let medicineCount: Int
}
