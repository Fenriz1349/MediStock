//
//  AisleLabel.swift
//  MediStock
//
//  Created by Julien Cotte on 07/08/2026.
//

import Foundation

/// Single point of resolution for the localized "aisle" word (e.g. "Rayon"/"Aisle").
/// Presentation-only — `AisleCode` (Domain) never resolves this itself.
enum AisleLabel {
    static var localized: String { String(localized: "medicineDetail.aisle.label") }
}
