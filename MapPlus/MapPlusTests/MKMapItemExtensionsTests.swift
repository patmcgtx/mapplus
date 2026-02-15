import Testing
import MapKit
import Contacts
@testable import MapPlus

struct MKMapItemExtensionsTests {
    
    // MARK: - Test Helpers
    
    /// Helper to create a test MKMapItem with specific properties
    /// Note: This helper creates items without address data. Tests using this helper
    /// will always fall back to coordinate-based descriptions.
    private static func createTestMapItem(
        coordinate: CLLocationCoordinate2D,
        name: String? = nil
    ) -> MKMapItem {
        // Create MKMapItem using modern API
        let mapItem = MKMapItem(
            location: CLLocation(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            ),
            address: nil
        )
        
        mapItem.name = name
        
        // Note: Address components cannot be set directly via public API in current iOS versions.
        // Tests using this helper verify coordinate-based fallback behavior.
        
        return mapItem
    }
    
    /// Helper to create a map item with just coordinates (no address)
    private static func createCoordinateOnlyMapItem(coordinate: CLLocationCoordinate2D) -> MKMapItem {
        let mapItem = MKMapItem(
            location: CLLocation(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            ),
            address: nil
        )
        return mapItem
    }
    
    // MARK: - fullDescription Tests
    
    @Test("fullDescription with name but no address (falls back to coordinates)")
    func testFullDescriptionWithNameAndAddress() {
        // Create a map item with name but no address (tests coordinate fallback)
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let mapItem = Self.createTestMapItem(
            coordinate: coordinate,
            name: "Awesome Cafe"
        )
        
        let description = mapItem.fullDescription
        
        // Without address data, should fall back to coordinates
        #expect(description.contains("37.77490") || description.contains("37,77490"), 
                "Description should contain latitude coordinate")
        
        // For coordinate-only fallback, check format
        let lines = description.split(separator: "\n")
        #expect(lines.count >= 1, "Description should have at least one line")
    }
    
    @Test("fullDescription with no address (falls back to coordinates)")
    func testFullDescriptionWithAddressOnly() {
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let mapItem = Self.createTestMapItem(
            coordinate: coordinate
        )
        
        let description = mapItem.fullDescription
        
        // Should fall back to coordinates since no address is set
        #expect(!description.isEmpty, "Description should not be empty")
        #expect(description.contains("37.77490") || description.contains("37,77490"), 
                "Description should contain coordinate")
    }
    
    @Test("fullDescription with name but no address (falls back to coordinates)")
    func testFullDescriptionWithNameInAddress() {
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let mapItem = Self.createTestMapItem(
            coordinate: coordinate,
            name: "Golden Gate Bridge"
        )
        
        let description = mapItem.fullDescription
        
        // Without address data, should fall back to coordinates
        #expect(!description.isEmpty, "Description should not be empty")
        #expect(description.contains("37.77490") || description.contains("37,77490"), 
                "Description should contain coordinate")
    }
    
    @Test("fullDescription with coordinates only (no address)")
    func testFullDescriptionWithCoordinatesOnly() {
        // Create a map item with just coordinates, no address
        let coordinate = CLLocationCoordinate2D(latitude: 37.33233, longitude: -122.03122)
        let mapItem = Self.createCoordinateOnlyMapItem(coordinate: coordinate)
        
        let description = mapItem.fullDescription
        
        // Should fall back to coordinate string
        // The exact format depends on locale, but should contain numbers
        #expect(description.contains("37.33233") || description.contains("37,33233"), 
                "Description should contain latitude")
        #expect(description.contains("122.03122") || description.contains("122,03122"), 
                "Description should contain longitude")
    }
    
    @Test("fullDescription with zero coordinates")
    func testFullDescriptionWithZeroCoordinates() {
        let coordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        let mapItem = Self.createCoordinateOnlyMapItem(coordinate: coordinate)
        
        let description = mapItem.fullDescription
        
        // Should show zero coordinates
        #expect(description.contains("0.00000") || description.contains("0,00000"), 
                "Description should contain zero coordinates")
    }
    
    @Test("fullDescription with negative coordinates")
    func testFullDescriptionWithNegativeCoordinates() {
        // Sydney, Australia - valid negative coordinates
        let coordinate = CLLocationCoordinate2D(latitude: -33.86882, longitude: 151.20929)
        let mapItem = Self.createCoordinateOnlyMapItem(coordinate: coordinate)
        
        let description = mapItem.fullDescription
        
        // Should handle negative latitude correctly
        #expect(description.contains("-33.86882") || description.contains("-33,86882"), 
                "Description should contain negative latitude")
        #expect(description.contains("151.20929") || description.contains("151,20929"), 
                "Description should contain positive longitude")
    }
    
    @Test("fullDescription with nil location")
    func testFullDescriptionWithNilLocation() {
        // Create a map item without a location (edge case)
        let mapItem = MKMapItem()
        
        let description = mapItem.fullDescription
        
        // Should have a fallback for nil location
        #expect(!description.isEmpty, "Description should not be empty even with nil location")
        #expect(description == "Unknown Location", "Should fall back to 'Unknown Location' for nil coordinates")
    }
    
    // MARK: - Parameterized Tests
    
    struct FullDescriptionTestCase {
        let coordinate: CLLocationCoordinate2D
        let hasAddress: Bool
        let name: String?
        let expectedToContain: [String]
        let testDescription: String
    }
    
    @Test("fullDescription with various scenarios", arguments: [
        FullDescriptionTestCase(
            coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
            hasAddress: false,
            name: "Central Park",
            expectedToContain: ["40.71280", "-74.00600"],
            testDescription: "Named location with coordinates"
        ),
        FullDescriptionTestCase(
            coordinate: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
            hasAddress: false,
            name: nil,
            expectedToContain: ["51.50740", "-0.12780"],
            testDescription: "Coordinates only without name"
        ),
        FullDescriptionTestCase(
            coordinate: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),
            hasAddress: false,
            name: "Tokyo Tower",
            expectedToContain: ["35.67620", "139.65030"],
            testDescription: "Named location with coordinates"
        )
    ])
    func testFullDescriptionVariousScenarios(testCase: FullDescriptionTestCase) {
        let mapItem = Self.createCoordinateOnlyMapItem(coordinate: testCase.coordinate)
        mapItem.name = testCase.name
        
        let description = mapItem.fullDescription
        
        for expectedString in testCase.expectedToContain {
            // Handle both period and comma decimal separators for locales
            let normalizedExpected = expectedString.replacingOccurrences(of: ".", with: ",")
            let hasExpected = description.contains(expectedString) || description.contains(normalizedExpected)
            #expect(hasExpected, 
                    "Description '\(description)' should contain '\(expectedString)' for \(testCase.testDescription)")
        }
    }
    
    @Test("fullDescription is not empty")
    func testFullDescriptionIsNeverEmpty() {
        // Even with minimal data, fullDescription should return something
        let coordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        let mapItem = Self.createCoordinateOnlyMapItem(coordinate: coordinate)
        
        let description = mapItem.fullDescription
        
        #expect(!description.isEmpty, "fullDescription should never be empty")
    }
    
    @Test("fullDescription coordinate precision")
    func testFullDescriptionCoordinatePrecision() {
        // Test that coordinates are formatted to exactly 5 decimal places
        let coordinate = CLLocationCoordinate2D(latitude: 37.123456789, longitude: -122.987654321)
        let mapItem = Self.createCoordinateOnlyMapItem(coordinate: coordinate)
        
        let description = mapItem.fullDescription
        
        // Extract coordinate components - they should be separated by a list separator
        // The coordinate string should match the pattern of 5 decimal places
        let coordinatePattern = "\\d+[.,]\\d{5}"
        let regex = try? NSRegularExpression(pattern: coordinatePattern)
        let range = NSRange(description.startIndex..., in: description)
        let matches = regex?.matches(in: description, range: range) ?? []
        
        // Should find at least 2 coordinate components (latitude and longitude)
        #expect(matches.count >= 2, "Should find at least 2 coordinate values with 5 decimal places")
        
        // Verify the specific values are present with correct precision
        let hasCorrectPrecisionLat = description.contains("37.12346") || description.contains("37,12346")
        let hasCorrectPrecisionLon = description.contains("122.98765") || description.contains("122,98765")
        
        #expect(hasCorrectPrecisionLat, "Latitude should be formatted to exactly 5 decimal places (37.12346)")
        #expect(hasCorrectPrecisionLon, "Longitude should be formatted to exactly 5 decimal places (122.98765)")
    }
}

