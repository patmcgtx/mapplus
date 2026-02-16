//
//  ViewExtensions.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/16/26.
//

import SwiftUI

extension View {
    
    /// Applies a glass morphism effect to the view with a frosted glass appearance.
    ///
    /// This modifier creates a modern, translucent glass effect with:
    /// - Semi-transparent background
    /// - Blur effect (ultra thin material)
    /// - Subtle border
    /// - Circular shape
    /// - Shadow for depth
    func glassEffect() -> some View {
        self
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
