//
//  MapPlusThemeGuts.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/5/26.
//
import SwiftUI

// TODO patmcg consider moving these to their own files
// TODO patmcg localize the names, etc.

struct ThemeModifiers {
    
    struct Standard: ViewModifier {
        func body(content: Content) -> some View {
            content
        }
    }
    
    struct EightBit: ViewModifier {
        func body(content: Content) -> some View {
            content
                .foregroundColor(.green)
                .fontDesign(.monospaced)
        }
    }
    
    struct Kerby: ViewModifier {
        func body(content: Content) -> some View {
            content
                .fontDesign(.rounded)
                .textCase(.uppercase)
                .foregroundColor(.orange)
        }
    }
    
}
