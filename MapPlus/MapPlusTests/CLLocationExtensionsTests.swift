import Testing
import CoreLocation
@testable import MapPlus

struct CLLocationExtensionsTests {
    
    // Test data for parameterized tests
    struct CoordinateTestCase {
        let latitude: Double
        let longitude: Double
        let expectedLatString: String
        let expectedLonString: String
        let description: String
    }
    
    @Test("Coordinate formatting", arguments: [
        CoordinateTestCase(
            latitude: 37.33233141,
            longitude: 122.03121860,
            expectedLatString: "37.33233",
            expectedLonString: "122.03122",
            description: "Positive coordinates"
        ),
        CoordinateTestCase(
            latitude: -33.86882,
            longitude: -151.20929,
            expectedLatString: "-33.86882",
            expectedLonString: "-151.20929",
            description: "Negative coordinates"
        ),
        CoordinateTestCase(
            latitude: 40.7128,
            longitude: -74.0060,
            expectedLatString: "40.71280",
            expectedLonString: "-74.00600",
            description: "Mixed positive/negative coordinates"
        ),
        CoordinateTestCase(
            latitude: 0.0,
            longitude: 0.0,
            expectedLatString: "0.00000",
            expectedLonString: "0.00000",
            description: "Zero coordinates"
        ),
        CoordinateTestCase(
            latitude: 90.0,
            longitude: 0.0,
            expectedLatString: "90.00000",
            expectedLonString: "0.00000",
            description: "Maximum latitude"
        ),
        CoordinateTestCase(
            latitude: -90.0,
            longitude: 0.0,
            expectedLatString: "-90.00000",
            expectedLonString: "0.00000",
            description: "Minimum latitude"
        ),
        CoordinateTestCase(
            latitude: 0.0,
            longitude: 180.0,
            expectedLatString: "0.00000",
            expectedLonString: "180.00000",
            description: "Maximum longitude"
        ),
        CoordinateTestCase(
            latitude: 0.0,
            longitude: -180.0,
            expectedLatString: "0.00000",
            expectedLonString: "-180.00000",
            description: "Minimum longitude"
        ),
        CoordinateTestCase(
            latitude: 37.81985,
            longitude: -122.47852,
            expectedLatString: "37.81985",
            expectedLonString: "-122.47852",
            description: "Real world location (Golden Gate Bridge)"
        ),
        CoordinateTestCase(
            latitude: 37.123456789,
            longitude: -122.987654321,
            expectedLatString: "37.12346",
            expectedLonString: "-122.98765",
            description: "High precision input with rounding"
        ),
        CoordinateTestCase(
            latitude: 1.00001,
            longitude: -1.00001,
            expectedLatString: "1.00001",
            expectedLonString: "-1.00001",
            description: "Small decimal values"
        )
    ])
    func testCoordinateStringFormatting(testCase: CoordinateTestCase) {
        let location = CLLocation(
            latitude: testCase.latitude,
            longitude: testCase.longitude
        )
        
        let coordinateString = location.coordinateString
        let coordinateComponents = Self.parseCoordinateComponents(from: coordinateString)
        
        // TODO patmcg verify the format is "latitude, longitude" / use different locales
        #expect(coordinateComponents.count == 2)
        #expect(coordinateComponents[0].contains(testCase.expectedLatString))
        #expect(coordinateComponents[1].contains(testCase.expectedLonString))
    }
    
    @Test("Decimal precision formatting", arguments: [
        (37.33233141, -122.03121860),
        (40.7128, -74.0060),
        (1.23456789, -9.87654321),
        (90.0, -180.0),
        (0.0, 0.0)
    ])
    func testCoordinateStringHasFiveDecimalPlaces(latitude: Double, longitude: Double) {
        let location = CLLocation(
            latitude: latitude,
            longitude: longitude
        )
        
        let coordinateString = location.coordinateString
        let coordinateComponents = Self.parseCoordinateComponents(from: coordinateString)
        
        #expect(coordinateComponents.count == 2)
        
        // Verify each component has a decimal point and exactly 5 decimal places
        for component in coordinateComponents {
            #expect(component.contains("."))
            if let decimalIndex = component.firstIndex(of: ".") {
                let decimalPart = component[component.index(after: decimalIndex)...]
                #expect(decimalPart.count == 5)
            }
        }
    }
    
    // Helper constants for separator detection
    private static let separatorDetectionSamples = ["A", "B"]
    
    // Helper function to parse coordinate components
    static func parseCoordinateComponents(from coordinateString: String) -> [String] {
        // Use ListFormatter to determine the separator pattern for the current locale
        let listFormatter = ListFormatter()
        listFormatter.locale = Locale.current
        
        // Generate a sample list to determine what separators ListFormatter uses
        let sample = listFormatter.string(from: separatorDetectionSamples) ?? "A, B"
        
        // For a two-item list, ListFormatter typically uses a simple separator
        // We need to extract that separator pattern
        // Common patterns: "A, B" (English), "A y B" (Spanish), "A und B" (German), etc.
        
        // Try to find the separator by removing the known items
        var separator = ", " // Default fallback
        if sample.hasPrefix(separatorDetectionSamples[0]) && sample.hasSuffix(separatorDetectionSamples[1]) {
            let middle = sample.dropFirst(separatorDetectionSamples[0].count).dropLast(separatorDetectionSamples[1].count)
            separator = String(middle)
        }
        
        // Split using the detected separator and trim whitespace
        let components = coordinateString.components(separatedBy: separator)
            .map { $0.trimmingCharacters(in: .whitespaces) }
        
        // If we didn't get exactly 2 components, try the fallback comma separator
        if components.count != 2 {
            return coordinateString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        }
        
        return components
    }
}
