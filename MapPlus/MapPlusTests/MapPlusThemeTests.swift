//
//  MapPlusThemeTests.swift
//  MapPlusTests
//

import SwiftUI
import Testing
@testable import MapPlus

struct MapPlusThemeTests {

    // MARK: - CaseIterable

    @Test func testCaseCount() {
        #expect(MapPlusTheme.allCases.count == 4)
    }

    @Test("All expected themes are present", arguments: [
        MapPlusTheme.cupertino,
        MapPlusTheme.eightBit,
        MapPlusTheme.kerby,
        MapPlusTheme.flamingo
    ])
    func testAllCasesPresent(theme: MapPlusTheme) {
        #expect(MapPlusTheme.allCases.contains(theme))
    }

    // MARK: - Identifiable

    @Test("id equals rawValue", arguments: MapPlusTheme.allCases)
    func testIdEqualsRawValue(theme: MapPlusTheme) {
        #expect(theme.id == theme.rawValue)
    }

    // MARK: - localizedName

    @Test("localizedName is non-empty", arguments: MapPlusTheme.allCases)
    func testLocalizedNameNonEmpty(theme: MapPlusTheme) {
        #expect(!theme.localizedName.isEmpty)
    }

    @Test("localizedName is unique per theme", arguments: zip(
        [MapPlusTheme.cupertino, MapPlusTheme.cupertino, MapPlusTheme.cupertino,
         MapPlusTheme.eightBit, MapPlusTheme.eightBit, MapPlusTheme.kerby],
        [MapPlusTheme.eightBit, MapPlusTheme.kerby, MapPlusTheme.flamingo,
         MapPlusTheme.kerby, MapPlusTheme.flamingo, MapPlusTheme.flamingo]
    ))
    func testLocalizedNamesAreUnique(themeA: MapPlusTheme, themeB: MapPlusTheme) {
        #expect(themeA.localizedName != themeB.localizedName)
    }

    // MARK: - fontDesign

    @Test("fontDesign", arguments: zip(
        [MapPlusTheme.cupertino, MapPlusTheme.eightBit, MapPlusTheme.kerby, MapPlusTheme.flamingo],
        [Font.Design.default,    Font.Design.monospaced, Font.Design.rounded, Font.Design.default]
    ))
    func testFontDesign(theme: MapPlusTheme, expectedDesign: Font.Design) {
        #expect(theme.fontDesign == expectedDesign)
    }

    // MARK: - fontWeight

    @Test("fontWeight", arguments: zip(
        [MapPlusTheme.cupertino, MapPlusTheme.eightBit, MapPlusTheme.kerby, MapPlusTheme.flamingo],
        [nil, nil, Font.Weight.bold, nil] as [Font.Weight?]
    ))
    func testFontWeight(theme: MapPlusTheme, expectedWeight: Font.Weight?) {
        #expect(theme.fontWeight == expectedWeight)
    }

    // MARK: - textCase

    @Test("textCase", arguments: zip(
        [MapPlusTheme.cupertino, MapPlusTheme.eightBit, MapPlusTheme.kerby, MapPlusTheme.flamingo],
        [nil, nil, Text.Case.uppercase, nil] as [Text.Case?]
    ))
    func testTextCase(theme: MapPlusTheme, expectedTextCase: Text.Case?) {
        #expect(theme.textCase == expectedTextCase)
    }

    // MARK: - menuIconName

    @Test("menuIconName", arguments: zip(
        [MapPlusTheme.cupertino, MapPlusTheme.eightBit, MapPlusTheme.kerby, MapPlusTheme.flamingo],
        ["paintbrush",           "paintbrush.fill",     "paintbrush.fill",   "paintbrush.fill"]
    ))
    func testMenuIconName(theme: MapPlusTheme, expectedIconName: String) {
        #expect(theme.menuIconName == expectedIconName)
    }

    // MARK: - foregroundColor

    @Test("foregroundColor is identical in light and dark for cupertino")
    func testForegroundColorCupertinoSameInBothSchemes() {
        #expect(MapPlusTheme.cupertino.foregroundColor(for: .light) ==
                MapPlusTheme.cupertino.foregroundColor(for: .dark))
    }

    @Test("foregroundColor differs between light and dark for color themes", arguments: [
        MapPlusTheme.eightBit,
        MapPlusTheme.kerby,
        MapPlusTheme.flamingo
    ])
    func testForegroundColorDiffersPerColorScheme(theme: MapPlusTheme) {
        #expect(theme.foregroundColor(for: .light) != theme.foregroundColor(for: .dark))
    }

    // MARK: - tintColor

    @Test("tintColor is nil for cupertino")
    func testTintColorCupertinoIsNil() {
        #expect(MapPlusTheme.cupertino.tintColor(for: .light) == nil)
        #expect(MapPlusTheme.cupertino.tintColor(for: .dark) == nil)
    }

    @Test("tintColor is non-nil for color themes", arguments: [
        MapPlusTheme.eightBit,
        MapPlusTheme.kerby,
        MapPlusTheme.flamingo
    ])
    func testTintColorNonNilForColorThemes(theme: MapPlusTheme) {
        #expect(theme.tintColor(for: .light) != nil)
        #expect(theme.tintColor(for: .dark) != nil)
    }

    @Test("tintColor is consistent across color schemes", arguments: [
        MapPlusTheme.eightBit,
        MapPlusTheme.kerby,
        MapPlusTheme.flamingo
    ])
    func testTintColorConsistentAcrossColorSchemes(theme: MapPlusTheme) {
        #expect(theme.tintColor(for: .light) == theme.tintColor(for: .dark))
    }
}
