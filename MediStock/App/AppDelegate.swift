//
//  AppDelegate.swift
//  MediStock
//
//  Created by Vincent Saluzzo on 28/05/2024.
//

import Foundation
import UIKit

/// Firebase is configured in `MediStockApp.init()`, not here: that runs before this delegate
/// callback fires, and `DIContainer`'s default Firestore/Firebase stores need it configured
/// by the time they're constructed.
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil)
    -> Bool {
        true
    }
}
