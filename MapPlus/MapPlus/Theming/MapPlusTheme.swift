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

    let theme: MapPlusTheme

    private static let flamingoPink = Color(red: 252/255, green: 142/255, blue: 172/255)

    func body(content: Content) -> some View {
        content
            .tint(tintColor)
            .foregroundStyle(foregroundColor)
            .fontDesign(fontDesign)
            .fontWeight(fontWeight)
            .textCase(textCase)
    }

    private var tintColor: Color? {
        switch theme {
        case .cupertino: return nil
        case .eightBit: return .green
        case .kerby: return .orange
        case .flamingo: return Self.flamingoPink
        }
    }

    private var foregroundColor: Color {
        switch theme {
        case .cupertino: return .primary
        case .eightBit: return .green
        case .kerby: return .orange
        case .flamingo: return Self.flamingoPink
        }
    }

    private var fontDesign: Font.Design {
        switch theme {
        case .eightBit: return .monospaced
        case .kerby: return .rounded
        default: return .default
        }
    }

    private var fontWeight: Font.Weight? {
        theme == .kerby ? .bold : nil
    }

    private var textCase: Text.Case? {
        theme == .kerby ? .uppercase : nil
    }

}
