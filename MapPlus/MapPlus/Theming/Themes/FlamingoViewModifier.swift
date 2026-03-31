//
//  FlamingoViewModifier.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/30/26.
//
import SwiftUI

/// Applies the "8-bit" style to a SwiftUI view hierarchy
struct FlamingoViewModifier: ViewModifier {
    
    private let flamingoPink = Color(red: 252/255, green: 142/255, blue: 172/255)
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(flamingoPink)
            .tint(flamingoPink)
    }
}

#Preview() {
    let theme = MapPlusTheme.flamingo
    ThemePreview(theme: theme)
        .apply(theme: theme)
}

