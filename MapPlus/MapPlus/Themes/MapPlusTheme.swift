//
//  MapPlusTheme.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/5/26.
//

/// Themes for styling the app
enum MapPlusTheme {
    
    /// The basic, default iOS theme
    case basic
    
    /// A fun, retro pixelated theme
    case eightBit
    
    /// An Austin-inspired theme
    case kerby
    
    // MARK: Methods
    
    var details: MapPlusThemeDetails {
        switch self {
        case .basic: return ThemeBasic()
        case .eightBit: return ThemeEightBit()
        case .kerby: return ThemeKerby()
        }
    }
}
