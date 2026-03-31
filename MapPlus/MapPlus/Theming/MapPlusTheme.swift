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
    case cupertino
    
    /// A fun, retro pixelated theme
    case eightBit
    
    /// An Austin-inspired cafe theme
    case kerby

    /// A Miami/flamingo-inspired theme
    case flamingo

    // MARK: Methods
    
    /// A localized user-facing name for the theme
    var localizedName: String {
        switch self {
        case .cupertino:
            return "theme-standard".localized
        case .eightBit:
            return "theme-eight-bit".localized
        case .kerby:
            return "theme-kerby".localized
        case .flamingo:
            return "theme-flamingo".localized
        }
    }

    /// Which icon should show for the overall themes menu
    var menuIconName: String {
        switch self {
        case .cupertino:
            return "paintbrush"
        default: return "paintbrush.fill"
        }
    }

}

extension View {

    // Note: I wanted to somehow embed the `ViewModifier` in the `MapPlusTheme` itself.
    //       However, `ViewModifier` is a protocol, and SwiftUI wants a concrete type
    //       for any `ViewModifier`.  I couldn't find a good/simple way to let `MapPlusTheme`
    //       return a protocol; it required an associated type, type-erasing, or other
    //       inefficiencies or complexities.  So I stopped fighting SwiftUI and did
    //       what it wants: just apply a simple, concrete `ViewModifier` directly.

    /// Applies the styling for the given `MapPlusTheme` to this view hierarchy.
    @ViewBuilder
    func apply(theme: MapPlusTheme) -> some View {
        switch theme {
        case .cupertino:
            self.modifier(CupertinoViewModifier())
        case .eightBit:
            self.modifier(EightBitViewModifier())
        case .kerby:
            self.modifier(KerbyViewModifier())
        case .flamingo:
            self.modifier(FlamingoViewModifier())
        }
    }

}
