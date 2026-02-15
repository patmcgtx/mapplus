import Testing
import MapKit
import Contacts
@testable import MapPlus

struct MKMapItemExtensionsTests {
    
    // MARK: - fullDescription Tests
    
    @Test("fullDescription with name and address")
    func testFullDescriptionWithNameAndAddress() {
        // Create a map item with both name and address
        let placemark = MKPlacemark(
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            addressDictionary: [
                CNPostalAddressStreetKey: "123 Main St",
                CNPostalAddressCityKey: "San Francisco",
                CNPostalAddressStateKey: "CA",
                CNPostalAddressPostalCodeKey: "94102"
            ]
        )
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Awesome Cafe"
        
        let description = mapItem.fullDescription
        
        // Should contain the name on a separate line since it's not in the address
        #expect(description.contains("Awesome Cafe"), "Description should contain the name")
        #expect(description.contains("123 Main St"), "Description should contain the street")
        #expect(description.contains("San Francisco"), "Description should contain the city")
        
        // Name should be on its own line (not part of address)
        let lines = description.split(separator: "\n")
        #expect(lines.count > 1, "Description should have multiple lines")
    }
    
    @Test("fullDescription with address only (no name)")
    func testFullDescriptionWithAddressOnly() {
        let placemark = MKPlacemark(
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            addressDictionary: [
                CNPostalAddressStreetKey: "456 Oak Ave",
                CNPostalAddressCityKey: "Berkeley",
                CNPostalAddressStateKey: "CA"
            ]
        )
        let mapItem = MKMapItem(placemark: placemark)
        
        let description = mapItem.fullDescription
        
        // Should contain address components
        #expect(description.contains("456 Oak Ave"), "Description should contain the street")
        #expect(description.contains("Berkeley"), "Description should contain the city")
    }
    
    @Test("fullDescription with name already in address")
    func testFullDescriptionWithNameInAddress() {
        let placemark = MKPlacemark(
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            addressDictionary: [
                CNPostalAddressStreetKey: "Golden Gate Bridge",
                CNPostalAddressCityKey: "San Francisco",
                CNPostalAddressStateKey: "CA"
            ]
        )
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Golden Gate Bridge"
        
        let description = mapItem.fullDescription
        
        // Name should not be duplicated since it's already in the address
        #expect(description.contains("Golden Gate Bridge"), "Description should contain the name")
        
        // Count occurrences - should only appear once (in the address)
        let occurrences = description.components(separatedBy: "Golden Gate Bridge").count - 1
        #expect(occurrences == 1, "Name should appear only once when it's already in the address")
    }
    
    @Test("fullDescription with coordinates only (no address)")
    func testFullDescriptionWithCoordinatesOnly() {
        // Create a map item with just coordinates, no address
        let coordinate = CLLocationCoordinate2D(latitude: 37.33233, longitude: -122.03122)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        
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
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        
        let description = mapItem.fullDescription
        
        // Should show zero coordinates
        #expect(description.contains("0.00000") || description.contains("0,00000"), 
                "Description should contain zero coordinates")
    }
    
    @Test("fullDescription with negative coordinates")
    func testFullDescriptionWithNegativeCoordinates() {
        let coordinate = CLLocationCoordinate2D(latitude: -33.86882, longitude: -151.20929)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        
        let description = mapItem.fullDescription
        
        // Should handle negative coordinates
        #expect(description.contains("-33.86882") || description.contains("-33,86882"), 
                "Description should contain negative latitude")
        #expect(description.contains("-151.20929") || description.contains("-151,20929") || 
                description.contains("151.20929") || description.contains("151,20929"), 
                "Description should contain negative longitude")
    }
    
    // MARK: - Parameterized Tests
    
    struct FullDescriptionTestCase {
        let coordinate: CLLocationCoordinate2D
        let addressDict: [String: Any]?
        let name: String?
        let expectedToContain: [String]
        let description: String
    }
    
    @Test("fullDescription with various scenarios", arguments: [
        FullDescriptionTestCase(
            coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
            addressDict: [
                CNPostalAddressCityKey: "New York",
                CNPostalAddressStateKey: "NY"
            ],
            name: "Central Park",
            expectedToContain: ["Central Park", "New York"],
            description: "City location with name"
        ),
        FullDescriptionTestCase(
            coordinate: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
            addressDict: [
                CNPostalAddressCityKey: "London"
            ],
            name: nil,
            expectedToContain: ["London"],
            description: "International city without name"
        ),
        FullDescriptionTestCase(
            coordinate: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),
            addressDict: nil,
            name: "Tokyo Tower",
            expectedToContain: ["35.67620", "139.65030"],
            description: "Named location with no address"
        )
    ])
    func testFullDescriptionVariousScenarios(testCase: FullDescriptionTestCase) {
        let placemark: MKPlacemark
        if let addressDict = testCase.addressDict {
            placemark = MKPlacemark(coordinate: testCase.coordinate, addressDictionary: addressDict)
        } else {
            placemark = MKPlacemark(coordinate: testCase.coordinate)
        }
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = testCase.name
        
        let description = mapItem.fullDescription
        
        for expectedString in testCase.expectedToContain {
            // Handle both period and comma decimal separators for locales
            let normalizedExpected = expectedString.replacingOccurrences(of: ".", with: ",")
            let hasExpected = description.contains(expectedString) || description.contains(normalizedExpected)
            #expect(hasExpected, 
                    "Description '\(description)' should contain '\(expectedString)' for \(testCase.description)")
        }
    }
    
    @Test("fullDescription is not empty")
    func testFullDescriptionIsNeverEmpty() {
        // Even with minimal data, fullDescription should return something
        let coordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        
        let description = mapItem.fullDescription
        
        #expect(!description.isEmpty, "fullDescription should never be empty")
    }
}
