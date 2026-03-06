//
//  MapPlusTheme.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/5/26.
//
import SwiftUI

/// Themes for styling the app
enum MapPlusTheme: String, CaseIterable, Identifiable {

    var id: String { self.rawValue }

    /// The basic, default iOS theme
    case standard
    
    /// A fun, retro pixelated theme
    case eightBit
    
    /// An Austin-inspired cafe theme
    case kerby

    // MARK: Methods
    
    // TODO patmcg actually localize
    var localizedName: String {
        switch self {
        case .standard:
            return "theme-standard"
                .localized
        case .eightBit:
            return "theme-eight-bit"
                .localized
        case .kerby:
            return "theme-kerby"
                .localized
        }
    }
}

extension View {

    /// Applies the styling for the given `MapPlusTheme` to this view heirarchy.
    @ViewBuilder func apply(theme: MapPlusTheme) -> some View {
        switch theme {
        case .standard:
            self.modifier(StandardViewModifier())
        case .eightBit:
            self.modifier(EightBitViewModifier())
        case .kerby:
            self.modifier(KerbyViewModifier())
        }
    }

}
