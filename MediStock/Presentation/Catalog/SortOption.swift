//
//  SortOption.swift
//  MediStock
//
//  Created by Julien Cotte on 04/08/2026.
//

/// Sort option for the all-medicines screen.
enum SortOption: String, CaseIterable, Identifiable {
    case none
    case name
    case stock

    var id: String { rawValue }
}
