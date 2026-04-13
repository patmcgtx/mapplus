//
//  MapPlusThemeTests.swift
//  MapPlusTests
//

import SwiftUI
import Testing
@testable import MapPlus

struct MapPlusThemeTests {

    // MARK: - Basics

    @Test func testCaseCount() {
        #expect(MapPlusTheme.allCases.count == 4)
    }

    @Test("All expected themes are present",
          arguments: [
            MapPlusTheme.cupertino,
            MapPlusTheme.eightBit,
            MapPlusTheme.kerby,
            MapPlusTheme.flamingo
          ]
    )
    func testAllCasesPresent(theme: MapPlusTheme) {
        #expect(MapPlusTheme.allCases.contains(theme))
    }

    @Test("id equals rawValue", arguments: MapPlusTheme.allCases)
    func testIdEqualsRawValue(theme: MapPlusTheme) {
        #expect(theme.id == theme.rawValue)
    }

    // MARK: - Localization

    struct LocalizationTestCase {
        let theme: MapPlusTheme
        let expectedLocalizedName: String
    }
    
    @Test(
        "Localized name",
        arguments: [
            LocalizationTestCase(
                theme: .cupertino,
                expectedLocalizedName: "Cupertino"
            ),
            LocalizationTestCase(
                theme: .eightBit,
                expectedLocalizedName: "8-bit"
            ),
            LocalizationTestCase(
                theme: .kerby,
                expectedLocalizedName: "Kerby"
            ),
            LocalizationTestCase(
                theme: .flamingo,
                expectedLocalizedName: "Flamingo"
            ),
          ]
    )
    func testLocalizedName(testCase: LocalizationTestCase) {
        #expect(!testCase.theme.localizedName.isEmpty)
        #expect(testCase.theme.localizedName != testCase.theme.rawValue)
        #expect(testCase.theme.localizedName == testCase.expectedLocalizedName)
    }

    // MARK: - Fonts and text
    
    struct FontTestCase {
        let theme: MapPlusTheme
        let expectedFontDesign: Font.Design
        let expectedFontWeight: Font.Weight?
        let expectedTextCase: Text.Case?
    }
    
    @Test("Fonts and text",
          arguments: [
            FontTestCase(
                theme: .cupertino,
                expectedFontDesign: .default,
                expectedFontWeight: nil,
                expectedTextCase: nil
            ),
            FontTestCase(
                theme: .eightBit,
                expectedFontDesign: .monospaced,
                expectedFontWeight: nil,
                expectedTextCase: nil
            ),
            FontTestCase(
                theme: .kerby,
                expectedFontDesign: .rounded,
                expectedFontWeight: .bold,
                expectedTextCase: .uppercase
            ),
            FontTestCase(
                theme: .flamingo,
                expectedFontDesign: .default,
                expectedFontWeight: nil,
                expectedTextCase: nil
            )
          ]
    )
    func testFontsAndText(testCase: FontTestCase) {
        #expect(testCase.theme.fontDesign == testCase.expectedFontDesign)
        #expect(testCase.theme.fontWeight == testCase.expectedFontWeight)
        #expect(testCase.theme.textCase == testCase.expectedTextCase)
    }

    // MARK: - Icons

    struct MenuIconTestCase {
        let theme: MapPlusTheme
        let expectedIconName: String
    }
    
    @Test(
        "menuIconName",
        arguments: [
            MenuIconTestCase(
                theme: .cupertino,
                expectedIconName: "paintbrush"
            ),
            MenuIconTestCase(
                theme: .eightBit,
                expectedIconName: "paintbrush.fill"
            ),
            MenuIconTestCase(
                theme: .kerby,
                expectedIconName: "paintbrush.fill"
            ),
            MenuIconTestCase(
                theme: .flamingo,
                expectedIconName: "paintbrush.fill"
            )
          ]
    )
    func testMenuIcon(testCase: MenuIconTestCase) {
        #expect(testCase.theme.menuIconName == testCase.expectedIconName)
    }

    // MARK: - Colors
    
    struct ColorTestCase {
        let theme: MapPlusTheme
        let expectedDarkModeForegroundColor: Color
        let expectedLightModeForegroundColor: Color
        let expectedTintColor: Color
    }
    
    @Test(
        "Colors",
        arguments: [
            ColorTestCase(
                theme: .cupertino,
                expectedDarkModeForegroundColor: .primary,
                expectedLightModeForegroundColor: .primary,
                expectedTintColor: .accentColor
            ),
            ColorTestCase(
                theme: .eightBit,
                expectedDarkModeForegroundColor: .green,
                expectedLightModeForegroundColor: Color(red: 0/255, green: 130/255, blue: 40/255),
                expectedTintColor: .green
            ),
            ColorTestCase(
                theme: .kerby,
                expectedDarkModeForegroundColor: .orange,
                expectedLightModeForegroundColor: Color(red: 175/255, green: 82/255, blue: 0/255),
                expectedTintColor: .orange
            ),
            ColorTestCase(
                theme: .flamingo,
                expectedDarkModeForegroundColor: Color(red: 252/255, green: 142/255, blue: 172/255),
                expectedLightModeForegroundColor: .pink,
                expectedTintColor: Color(red: 252/255, green: 142/255, blue: 172/255)
            )
          ]
    )
    func testColors(testCase: ColorTestCase) {
        #expect(testCase.theme.foregroundColor(for: .light) == testCase.expectedLightModeForegroundColor)
        #expect(testCase.theme.foregroundColor(for: .dark) == testCase.expectedDarkModeForegroundColor)
        #expect(testCase.theme.tintColor == testCase.expectedTintColor)
    }

}
