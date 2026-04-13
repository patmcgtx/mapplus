//
//  ThemeViewModifier.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 4/5/26.
//
import SwiftUI

/// A single `ViewModifier` that applies theme-specific styling based on the given `MapPlusTheme`.
///
/// Consolidating all theme variants into one modifier ensures the structural type of the
/// modified view never changes when the theme changes, so SwiftUI preserves view identity
/// and does not reset state such as the map camera position.
struct ThemeViewModifier: ViewModifier {

    /// The theme to apply
    let theme: MapPlusTheme

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .tint(theme.tintColor)
            .foregroundStyle(theme.foregroundColor(for: colorScheme))
            .fontDesign(theme.fontDesign)
            .fontWeight(theme.fontWeight)
            .textCase(theme.textCase)
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
