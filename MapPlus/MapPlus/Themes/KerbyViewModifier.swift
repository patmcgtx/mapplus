//
//  KerbyViewModifier.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/5/26.
//
import SwiftUI

struct KerbyViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .fontDesign(.rounded)
            .textCase(.uppercase)
            .foregroundColor(.orange)
    }
}

#Preview() {
    let theme = MapPlusTheme.kerby
    ThemePreview(theme: theme)
        .apply(theme: theme)
}
