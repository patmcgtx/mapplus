//
//  MapPlusTheme.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/5/26.
//
import SwiftUI

/// Themes for styling the app
enum MapPlusTheme: String, CaseIterable, Identifiable {
    
    /// The basic, default iOS theme
    case standard
    
    /// A fun, retro pixelated theme
    case eightBit
    
    /// An Austin-inspired theme
    case kerby

    var id: String { self.rawValue }

    // MARK: Methods
    
    // TODO patmcg actually localize
    var localizedName: String {
        switch self {
        case .standard:
            return "Standard"
        case .eightBit:
            return "Eight Bit"
        case .kerby:
            return "Kerby"
        }
    }
}

extension View {

    /// Applies the styling for the given `MapPlusTheme` to this view.
    @ViewBuilder func apply(theme: MapPlusTheme) -> some View {
        switch theme {
        case .standard:
            self.modifier(ThemeModifiers.Standard())
        case .eightBit:
            self.modifier(ThemeModifiers.EightBit())
        case .kerby:
            self.modifier(ThemeModifiers.Kerby())
        }
    }

}
