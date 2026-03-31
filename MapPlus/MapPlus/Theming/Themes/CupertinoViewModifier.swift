//
//  StandardViewModifier.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/5/26.
//
import SwiftUI

/// Applies the standard "Cupertino"  style to a SwiftUI view hierarchy
struct CupertinoViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content // Change nothing! haha
    }
}

#Preview() {
    let theme = MapPlusTheme.cupertino
    ThemePreview(theme: theme)
        .apply(theme: theme)
}
