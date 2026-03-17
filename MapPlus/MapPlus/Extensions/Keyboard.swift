//
//  Keyboard.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/16/26.
//
import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
