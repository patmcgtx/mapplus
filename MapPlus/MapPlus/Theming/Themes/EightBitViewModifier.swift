//
//  EightBitViewModifier.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/5/26.
//
import SwiftUI

/// Applies the "8-bit" style to a SwiftUI view hierarchy
struct EightBitViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.green)
            .tint(.green)
            .fontDesign(.monospaced)
    }
}

#Preview() {
    let theme = MapPlusTheme.eightBit
    ThemePreview(theme: theme)
        .apply(theme: theme)
}
