//
//  MapPlusTheme.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/5/26.
//

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
