//
//  EightBitViewModifier.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/5/26.
//
import SwiftUI

struct EightBitViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.green)
            .fontDesign(.monospaced)
            .tint(.green)
    }
}

#Preview() {
    let theme = MapPlusTheme.eightBit
    ThemePreview(theme: theme)
        .apply(theme: theme)
}
