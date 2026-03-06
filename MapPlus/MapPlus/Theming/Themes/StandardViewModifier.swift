//
//  StandardViewModifier.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/5/26.
//
import SwiftUI

/// Applies the "standard" style to a SwiftUI view hierarchy
struct StandardViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}

#Preview() {
    let theme = MapPlusTheme.standard
    ThemePreview(theme: theme)
        .apply(theme: theme)
}
