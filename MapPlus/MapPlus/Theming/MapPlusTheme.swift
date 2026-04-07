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
    
    /// Which font design to use for the app's text
    var fontDesign: Font.Design {
        switch self {
        case .eightBit: return .monospaced
        case .kerby: return .rounded
        default: return .default
        }
    }
    
    /// Which special font weight to show text in, if any
    var fontWeight: Font.Weight? {
        switch self {
        case .kerby: return .bold
        default: return nil
        }
    }
    
    /// Which special case to show text in, if any
    var textCase: Text.Case? {
        switch self {
        case .kerby: return .uppercase
        default : return nil
        }
    }

    /// Which icon should show for the overall themes menu
    var menuIconName: String {
        switch self {
        case .cupertino: return "paintbrush"
        default: return "paintbrush.fill"
        }
    }

    /// The primary color used for text;  must have a high contrast.
    func foregroundColor(for colorScheme: ColorScheme) -> Color {
        switch self {
        case .cupertino: return .primary
        case .eightBit: return highContrastGreen(for: colorScheme)
        case .kerby: return highContrastOrange(for: colorScheme)
        case .flamingo: return highContrastPink(for: colorScheme)
        }
    }

    /// A secondary color for some icons, backgrounds, etc.
    func tintColor(for colorScheme: ColorScheme) -> Color? {
        switch self {
        case .cupertino: return nil
        case .eightBit: return .green
        case .kerby: return .orange
        case .flamingo: return softFlamingoPink
        }
    }

    // MARK: Private helpers
    
    /// A high-contrast variation of 8-bit green specialized for text in dark or light mode
    private func highContrastGreen(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark: return .green
        default: return Color(red: 0/255, green: 130/255, blue: 40/255)
        }
    }

    /// Returns a variation of orange specialized for text in light or dark mode
    private func highContrastOrange(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark: return .orange
        default: return Color(red: 175/255, green: 82/255, blue: 0/255)
        }
    }

    private func highContrastPink(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark: return softFlamingoPink
        default: return .pink
        }
    }

    /// A softer variation of pink for accents and backgrounds
    private var softFlamingoPink: Color {
        Color(red: 252/255, green: 142/255, blue: 172/255)
    }
}
