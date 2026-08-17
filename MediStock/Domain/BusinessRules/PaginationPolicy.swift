//
//  PaginationPolicy.swift
//  MediStock
//
//  Created by Julien Cotte on 14/08/2026.
//

import Foundation

/// How many results a paginated list requests at once.
/// Shared by every screen that lazily loads a medicine list, so the page size stays consistent app-wide.
enum PaginationPolicy {
    /// Requested on the first load.
    static let initialPageSize = 20
    /// Added to the current limit each time `loadMore()` is called.
    static let increment = 20
}
