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
    
    var modifier: any ViewModifier { get }
}

/// Type-erased wrapper that allows an `any ViewModifier` existential to be used
/// where a concrete `ViewModifier`-conforming type is required (e.g. `View.modifier(_:)`).
struct AnyViewModifier: ViewModifier {
    private let _apply: (AnyView) -> AnyView

    init(_ wrapped: any ViewModifier) {
        func makeApply<M: ViewModifier>(_ m: M) -> (AnyView) -> AnyView {
            { AnyView($0.modifier(m)) }
        }
        self._apply = makeApply(wrapped)
    }

    func body(content: Content) -> some View {
        _apply(AnyView(content))
    }
}

// TODO patmcg consider moving these to their own files
// TODO patmcg localize the names, etc.

struct ThemeEightBit: MapPlusThemeDetails {

    var modifier: any ViewModifier { EightBitModifier() as any ViewModifier}
    
    var name: String { "8-bit" }
    
    struct EightBitModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .foregroundColor(.white)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}

struct ThemeBasic: MapPlusThemeDetails {

    var modifier: any ViewModifier { BasicModifier() as any ViewModifier }
    
    var name: String { "Basic" }
    
    struct BasicModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .foregroundColor(.white)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}

struct ThemeKerby: MapPlusThemeDetails {
    var modifier: any ViewModifier { KerbyViewModifer() as any ViewModifier }
    
    var name: String { "Kerby" }
    
    struct KerbyViewModifer: ViewModifier {
        func body(content: Content) -> some View {
            content
                .foregroundColor(.white)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}
