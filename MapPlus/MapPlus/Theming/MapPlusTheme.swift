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
    
    /// Which font design ti show text in
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
        case .kerby: return kerbyOrange(for: colorScheme)
        case .flamingo: return .pink
        }
    }

    /// A secondary color for some icons, backgrounds, etc.
    func tintColor(for colorScheme: ColorScheme) -> Color? {
        switch self {
        case .cupertino: return nil
        case .eightBit: return .green
        case .kerby: return .orange
        case .flamingo: return softFlamingoPink(for: colorScheme)
        }
    }

    // MARK: Private helpers
    
    /// A high-contrast variation of 8-bit green specialized for text in dark or light mode
    private func highContrastGreen(for colorScheme: ColorScheme) -> Color {
        Color(red: 0/255, green: 130/255, blue: 40/255)
    }

    /// Returns a variation of orange specialized for light or dark mode
    private func kerbyOrange(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark: return .orange
        default: return Color(red: 175/255, green: 82/255, blue: 0/255)
        }
    }

    /// A softer variation of pink for accents and backgrounds
    private func softFlamingoPink(for colorScheme: ColorScheme) -> Color {
        Color(red: 252/255, green: 142/255, blue: 172/255)
    }
}

extension View {

    /// Applies the styling for the given `MapPlusTheme` to this view hierarchy.
    ///
    /// Uses a single concrete `ThemeViewModifier` so the view hierarchy type never changes
    /// when the theme switches, preserving view identity and associated state (e.g. map camera position).
    func apply(theme: MapPlusTheme) -> some View {
        self.modifier(ThemeViewModifier(theme: theme))
    }

}

/// A single `ViewModifier` that applies theme-specific styling based on the given `MapPlusTheme`.
///
/// Consolidating all theme variants into one modifier ensures the structural type of the
/// modified view never changes when the theme changes, so SwiftUI preserves view identity
/// and does not reset state such as the map camera position.
private struct ThemeViewModifier: ViewModifier {

    /// The theme to apply
    let theme: MapPlusTheme

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .tint(theme.tintColor(for: colorScheme))
            .foregroundStyle(theme.foregroundColor(for:  colorScheme))
            .fontDesign(theme.fontDesign)
            .fontWeight(theme.fontWeight)
            .textCase(theme.textCase)
    }

}
