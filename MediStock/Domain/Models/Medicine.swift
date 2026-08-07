//
//  Medicine.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

import Foundation

/// A stocked medicine reference, located in a given aisle with a tracked quantity.
struct Medicine: Identifiable, Codable, Equatable, Hashable {
    var id: String?
    var name: String
    var stock: Int
    var aisle: String
}
