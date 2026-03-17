//
//  Keyboard.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/16/26.
//
import SwiftUI

extension View {
    
    /// Hides the active keyboard.
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

extension UIKeyboardType {
    
    /// Secret key to the built-in emoji keyboard.
    static let emoji = UIKeyboardType(rawValue: 124)
}
