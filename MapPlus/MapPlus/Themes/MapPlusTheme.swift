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
    case basic = "basic"
    
    /// A fun, retro pixelated theme
    case eightBit = "eightBit"
    
    /// An Austin-inspired theme
    case kerby = "kerby"

    var id: String { self.rawValue }

    // MARK: Methods
    
    var details: MapPlusThemeDetails {
        switch self {
        case .basic: return ThemeBasic()
        case .eightBit: return ThemeEightBit()
        case .kerby: return ThemeKerby()
        }
    }
    
}

extension View {

    /// Applies the styling for the given `MapPlusTheme` to this view.
    @ViewBuilder func mapPlusTheme(_ theme: MapPlusTheme) -> some View {
        switch theme {
        case .basic:
            self.modifier(ThemeBasic.BasicModifier())
        case .eightBit:
            self.modifier(ThemeEightBit.EightBitModifier())
        case .kerby:
            self.modifier(ThemeKerby.KerbyViewModifier())
        }
    }

}
