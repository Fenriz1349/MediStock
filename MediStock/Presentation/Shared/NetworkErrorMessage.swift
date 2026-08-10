//
//  NetworkErrorMessage.swift
//  MediStock
//
//  Created by Julien Cotte on 10/08/2026.
//

import Foundation

/// Localized text for each `NetworkError` case.
/// Kept out of the Domain/ViewModel layers since it touches the display language.
/// Shared by `MedicineErrorMessage`/`AuthenticationErrorMessage`, so the wording only lives once.
extension NetworkError {
    var localizedMessage: String {
        switch self {
        case .notConnected: String(localized: "network.error.notConnected")
        case .serverUnreachable: String(localized: "network.error.serverUnreachable")
        }
    }
}
