//
//  AccessibilityHandler.swift
//  MediStock
//
//  Created by Julien Cotte on 13/08/2026.
//

import Foundation

/// Centralizes VoiceOver labels for rows composed of several `Text`s.
/// Reading them as-is would sound like disconnected fragments instead of a sentence.
enum AccessibilityHandler {
    enum MedicineRow {
        static func label(name: String, stock: Int) -> String {
            String(localized: "accessibility.medicineRow.label", defaultValue: "\(name), stock de \(stock)")
        }
    }

    enum AisleRow {
        static func label(aisle: String, medicineCount: Int) -> String {
            if medicineCount == 1 {
                return String(localized: "accessibility.aisleRow.labelSingular",
                              defaultValue: "\(aisle), 1 médicament")
            }
            return String(localized: "accessibility.aisleRow.labelPlural",
                          defaultValue: "\(aisle), \(medicineCount) médicaments")
        }
    }

    enum MedicineDetail {
        static func summary(name: String, aisle: String, stock: Int) -> String {
            String(localized: "accessibility.medicineDetail.summary",
                   defaultValue: "\(name), \(aisle), stock de \(stock)")
        }
    }
}
