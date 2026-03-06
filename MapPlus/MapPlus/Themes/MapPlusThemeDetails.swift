//
//  MapPlusThemeGuts.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/5/26.
//
import SwiftUI

/// The "guts" of a theme.
protocol MapPlusThemeDetails {
    
    // TODO patmcg doc
    var name: String { get }
}

// TODO patmcg consider moving these to their own files
// TODO patmcg localize the names, etc.

struct ThemeStandard: MapPlusThemeDetails {

    var name: String { "Cupertino" }
    
    struct BasicModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
        }
    }
}

struct ThemeEightBit: MapPlusThemeDetails {

    var name: String { "8-bit" }
    
    struct EightBitModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .foregroundColor(.green)
                .fontDesign(.monospaced)
        }
    }
}

struct ThemeKerby: MapPlusThemeDetails {
    
    var name: String { "Kerby" }
    
    struct KerbyViewModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .fontDesign(.rounded)
                .textCase(.uppercase)
                .foregroundColor(.orange)
        }
    }
}
