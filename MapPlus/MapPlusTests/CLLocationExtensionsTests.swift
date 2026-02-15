import Testing
import CoreLocation
@testable import MapPlus

struct CLLocationExtensionsTests {
    
    @Test func testCoordinateStringWithPositiveCoordinates() {
        let location = CLLocation(
            latitude: 37.33233141,
            longitude: 122.03121860
        )
        
        let coordinateString = location.coordinateString
        
        // Verify it contains formatted coordinates
        #expect(coordinateString.contains("37.33233"))
        #expect(coordinateString.contains("122.03122"))
        #expect(coordinateString.contains(","))
    }
    
    @Test func testCoordinateStringWithNegativeCoordinates() {
        let location = CLLocation(
            latitude: -33.86882,
            longitude: -151.20929
        )
        
        let coordinateString = location.coordinateString
        
        // Verify it contains formatted coordinates with negative signs
        #expect(coordinateString.contains("-33.86882"))
        #expect(coordinateString.contains("-151.20929"))
        #expect(coordinateString.contains(","))
    }
    
    @Test func testCoordinateStringWithMixedCoordinates() {
        let location = CLLocation(
            latitude: 40.7128,
            longitude: -74.0060
        )
        
        let coordinateString = location.coordinateString
        
        // Verify it contains formatted coordinates
        #expect(coordinateString.contains("40.71280"))
        #expect(coordinateString.contains("-74.00600"))
        #expect(coordinateString.contains(","))
    }
    
    @Test func testCoordinateStringWithZeroCoordinates() {
        let location = CLLocation(
            latitude: 0.0,
            longitude: 0.0
        )
        
        let coordinateString = location.coordinateString
        
        // Verify it formats zero correctly
        #expect(coordinateString.contains("0.00000"))
        #expect(coordinateString.contains(","))
    }
    
    @Test func testCoordinateStringFormattingPrecision() {
        let location = CLLocation(
            latitude: 37.33233141,
            longitude: -122.03121860
        )
        
        let coordinateString = location.coordinateString
        
        // The formatter should format to exactly 5 decimal places
        let components = coordinateString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        #expect(components.count == 2)
        
        // Verify each component has exactly 5 decimal places
        for component in components {
            if let decimalIndex = component.firstIndex(of: ".") {
                let decimalPart = component[component.index(after: decimalIndex)...]
                // Remove any negative sign for counting
                let cleanDecimalPart = decimalPart.replacingOccurrences(of: "-", with: "")
                #expect(cleanDecimalPart.count == 5)
            }
        }
    }
    
    @Test func testCoordinateStringWithMaximumLatitude() {
        let location = CLLocation(
            latitude: 90.0,
            longitude: 0.0
        )
        
        let coordinateString = location.coordinateString
        
        // Verify it handles maximum latitude
        #expect(coordinateString.contains("90.00000"))
    }
    
    @Test func testCoordinateStringWithMinimumLatitude() {
        let location = CLLocation(
            latitude: -90.0,
            longitude: 0.0
        )
        
        let coordinateString = location.coordinateString
        
        // Verify it handles minimum latitude
        #expect(coordinateString.contains("-90.00000"))
    }
    
    @Test func testCoordinateStringWithMaximumLongitude() {
        let location = CLLocation(
            latitude: 0.0,
            longitude: 180.0
        )
        
        let coordinateString = location.coordinateString
        
        // Verify it handles maximum longitude
        #expect(coordinateString.contains("180.00000"))
    }
    
    @Test func testCoordinateStringWithMinimumLongitude() {
        let location = CLLocation(
            latitude: 0.0,
            longitude: -180.0
        )
        
        let coordinateString = location.coordinateString
        
        // Verify it handles minimum longitude
        #expect(coordinateString.contains("-180.00000"))
    }
    
    @Test func testCoordinateStringWithRealWorldLocations() {
        // Test with known locations
        let goldenGate = CLLocation(
            latitude: 37.81985,
            longitude: -122.47852
        )
        
        let coordinateString = goldenGate.coordinateString
        
        // Verify it formats real-world coordinates
        #expect(coordinateString.contains("37.81985"))
        #expect(coordinateString.contains("-122.47852"))
    }
    
    @Test func testCoordinateStringWithHighPrecisionInput() {
        // Test with very high precision input to ensure proper rounding
        let location = CLLocation(
            latitude: 37.123456789,
            longitude: -122.987654321
        )
        
        let coordinateString = location.coordinateString
        
        // Should be rounded to 5 decimal places
        #expect(coordinateString.contains("37.12346"))
        #expect(coordinateString.contains("-122.98765"))
    }
    
    @Test func testCoordinateStringWithSmallDecimals() {
        let location = CLLocation(
            latitude: 1.00001,
            longitude: -1.00001
        )
        
        let coordinateString = location.coordinateString
        
        // Verify small decimals are formatted correctly
        #expect(coordinateString.contains("1.00001"))
        #expect(coordinateString.contains("-1.00001"))
    }
}
