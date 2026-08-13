//
//  KeyboardToolBar.swift
//  MediStock
//
//  Created by Julien Cotte on 11/08/2026.
//

import SwiftUI

/// "Close"/"Validate" button pair shown above the keyboard on data-entry screens.
/// "Close" just dismisses the keyboard; "Validate" dismisses it, then runs the screen's primary action.
struct KeyboardToolBar: ToolbarContent {
    let isValidateEnabled: Bool
    let onValidate: () -> Void

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Button("keyboard.closeButton") {
                Self.dismissKeyboard()
            }
            Spacer()
            Button("keyboard.validateButton") {
                Self.dismissKeyboard()
                onValidate()
            }
            .disabled(!isValidateEnabled)
        }
    }

    /// Resigns whichever field currently has focus, regardless of which one that is.
    /// Simpler than threading a `FocusState` through every screen's fields just for this.
    private static func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
