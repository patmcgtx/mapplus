//
//  AppTheme.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/1/26.
//

import SwiftUI

/// The visual theme of the app.
enum AppTheme: String, CaseIterable {
    /// The standard default theme.
    case standard
    /// A pixelated retro "8-bit" theme.
    case eightBit = "8-bit"
    
    /// A human-readable display name for the theme.
    var displayName: String {
        switch self {
        case .standard: return "Standard"
        case .eightBit: return "8-Bit"
        }
    }
}
