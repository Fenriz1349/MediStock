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

    enum StockButton {
        static func decreaseLabel(stock: Int) -> String {
            String(localized: "accessibility.stockButton.decrease",
                   defaultValue: "Diminuer, stock de \(stock) à \(stock - 1)")
        }

        static func increaseLabel(stock: Int) -> String {
            String(localized: "accessibility.stockButton.increase",
                   defaultValue: "Augmenter, stock de \(stock) à \(stock + 1)")
        }
    }

    enum SortButton {
        static func label(ascending: Bool) -> String {
            ascending
                ? String(localized: "accessibility.sortButton.ascending", defaultValue: "Trier par ordre croissant")
                : String(localized: "accessibility.sortButton.descending", defaultValue: "Trier par ordre décroissant")
        }
    }
}
