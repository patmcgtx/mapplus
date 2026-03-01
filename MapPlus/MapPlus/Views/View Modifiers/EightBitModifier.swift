//
//  EightBitModifier.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/1/26.
//

import SwiftUI

/// View modifier that applies a pixelated retro "8-bit" style to a view.
struct EightBitModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .fontDesign(.monospaced)
            .tint(.green)
    }
}

extension View {

    /// Applies the 8-bit pixelated retro style to this view.
    func eightBitStyle() -> some View {
        modifier(EightBitModifier())
    }
}
