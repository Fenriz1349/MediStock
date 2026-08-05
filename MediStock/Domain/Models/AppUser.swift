//
//  AppUser.swift
//  MediStock
//
//  Created by Julien Cotte on 24/07/2026.
//

/// A signed-in application user, derived from the authentication provider's session.
struct AppUser: Equatable {
    let uid: String
    let email: String?
}
