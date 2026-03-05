//
//  MapPlusThemeGuts.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/5/26.
//

/// The "guts" of a theme.
protocol MapPlusThemeDetails {
    // TODO patmcg doc
    var name: String { get }
}

// TODO patmcg consider moving these to their own files
// TODO patmcg localize the names, etc.

struct ThemeEightBit: MapPlusThemeDetails {
    var name: String { "8-bit" }
}

struct ThemeBasic: MapPlusThemeDetails {
    var name: String { "Basic" }
}

struct ThemeKerby: MapPlusThemeDetails {
    var name: String { "Kerby" }
}
