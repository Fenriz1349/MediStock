//
//  MedicineErrorMessage.swift
//  MediStock
//
//  Created by Julien Cotte on 07/08/2026.
//

import Foundation

/// Localized text for each `MedicineError` case, kept out of the Domain/ViewModel layers since it
/// touches the display language.
extension MedicineError {
    var localizedMessage: String {
        switch self {
        case .networkUnavailable: String(localized: "medicine.error.networkUnavailable")
        case .permissionDenied: String(localized: "medicine.error.permissionDenied")
        case .unknown: String(localized: "medicine.error.unknown")
        }
    }
}
