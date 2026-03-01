import Testing
@testable import MapPlus

struct AppThemeTests {

    @Test("AppTheme raw values")
    func testRawValues() {
        #expect(AppTheme.standard.rawValue == "standard")
        #expect(AppTheme.eightBit.rawValue == "8-bit")
    }

    @Test("AppTheme display names")
    func testDisplayNames() {
        #expect(AppTheme.standard.displayName == "Standard")
        #expect(AppTheme.eightBit.displayName == "8-Bit")
    }

    @Test("AppTheme initializable from raw value")
    func testInitFromRawValue() {
        #expect(AppTheme(rawValue: "standard") == .standard)
        #expect(AppTheme(rawValue: "8-bit") == .eightBit)
        #expect(AppTheme(rawValue: "unknown") == nil)
    }

    @Test("AppTheme allCases contains all themes")
    func testAllCases() {
        #expect(AppTheme.allCases.count == 2)
        #expect(AppTheme.allCases.contains(.standard))
        #expect(AppTheme.allCases.contains(.eightBit))
    }
}
