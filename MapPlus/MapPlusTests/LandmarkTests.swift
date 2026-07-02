// Thanks, Claude Sonnet

import Testing
import MapKit
import SwiftData
@testable import MapPlus

@MainActor
struct LandmarkTests {
    
    // Test data for parameterized landmark initialization tests
    struct LandmarkTestCase {
        let name: String
        let notes: String
        let formattedAddress: String
        let symbol: String
        let latitude: CLLocationDegrees
        let longitude: CLLocationDegrees
        let description: String
    }
    
    @Test("Landmark initialization", arguments: [
        LandmarkTestCase(
            name: "Golden Gate Bridge",
            notes: "bridge",
            formattedAddress: "San Francisco, CA",
            symbol: "🌉",
            latitude: 37.81985,
            longitude: -122.47852,
            description: "Golden Gate Bridge"
        ),
        LandmarkTestCase(
            name: "Sunny Beach Pocket Park",
            notes: "Nice small beach with amenities",
            formattedAddress: "123 Beach Rd, Sunnyville",
            symbol: "🏖️",
            latitude: 29.23755,
            longitude: -94.87794,
            description: "Beach park"
        ),
        LandmarkTestCase(
            name: "Smithville",
            notes: "",
            formattedAddress: "Smithville, TX",
            symbol: "📍",
            latitude: 30.00458,
            longitude: -97.14810,
            description: "Smithville"
        ),
        LandmarkTestCase(
            name: "Central Park",
            notes: "Large urban park",
            formattedAddress: "New York, NY",
            symbol: "🌳",
            latitude: 40.785091,
            longitude: -73.968285,
            description: "Central Park"
        ),
        LandmarkTestCase(
            name: "Empty Notes Location",
            notes: "",
            formattedAddress: "Test Address",
            symbol: "📌",
            latitude: 0.0,
            longitude: 0.0,
            description: "Location with empty notes"
        )
    ])
    func testLandmarkInitialization(testCase: LandmarkTestCase) {
        let coordinate = CLLocationCoordinate2D(
            latitude: testCase.latitude,
            longitude: testCase.longitude
        )
        let landmark = Landmark(
            name: testCase.name,
            notes: testCase.notes,
            formattedAddress: testCase.formattedAddress,
            symbol: testCase.symbol,
            location: coordinate
        )
        
        #expect(landmark.name == testCase.name,
                "Expected name '\(testCase.name)' for \(testCase.description)")
        #expect(landmark.notes == testCase.notes,
                "Expected notes '\(testCase.notes)' for \(testCase.description)")
        #expect(landmark.formattedAddress == testCase.formattedAddress,
                "Expected address '\(testCase.formattedAddress)' for \(testCase.description)")
        #expect(landmark.symbol == testCase.symbol,
                "Expected symbol '\(testCase.symbol)' for \(testCase.description)")
        #expect(landmark.location.latitude == coordinate.latitude,
                "Expected latitude \(coordinate.latitude) for \(testCase.description)")
        #expect(landmark.location.longitude == coordinate.longitude,
                "Expected longitude \(coordinate.longitude) for \(testCase.description)")
    }
    
    // Test data for coordinate property tests
    struct CoordinateTestCase {
        let latitude: CLLocationDegrees
        let longitude: CLLocationDegrees
        let description: String
    }
    
    @Test("Coordinate computed property", arguments: [
        CoordinateTestCase(
            latitude: 29.23755,
            longitude: -94.87794,
            description: "Beach park coordinates"
        ),
        CoordinateTestCase(
            latitude: 37.81985,
            longitude: -122.47852,
            description: "Golden Gate Bridge coordinates"
        ),
        CoordinateTestCase(
            latitude: 0.0,
            longitude: 0.0,
            description: "Zero coordinates"
        ),
        CoordinateTestCase(
            latitude: -33.86882,
            longitude: 151.20929,
            description: "Southern hemisphere coordinates"
        ),
        CoordinateTestCase(
            latitude: 90.0,
            longitude: 180.0,
            description: "Extreme coordinates"
        )
    ])
    func testCoordinateComputedProperty(testCase: CoordinateTestCase) {
        let landmark = Landmark(
            name: "Test Location",
            notes: "Test",
            formattedAddress: "Test Address",
            symbol: "📌",
            location: .init(
                latitude: testCase.latitude,
                longitude: testCase.longitude
            )
        )
        
        #expect(landmark.location.latitude == testCase.latitude,
                "Expected latitude \(testCase.latitude) for \(testCase.description)")
        #expect(landmark.location.longitude == testCase.longitude,
                "Expected longitude \(testCase.longitude) for \(testCase.description)")
    }
    
    @Test("Two landmarks at the same coordinates share a location") func testUniqueness() {
        
        let coordinate = CLLocationCoordinate2D(
            latitude: 30.00458,
            longitude: -97.14810
        )
        let smithville = Landmark(
            name: "Smithville",
            notes: "",
            formattedAddress: "Smithville, TX",
            symbol: "📍",
            location: coordinate
        )
        let smithville4thStreet = Landmark(
            name: "4th Street",
            notes: "",
            formattedAddress: "4th St, Smithville, TX",
            symbol: "📌",
            location: coordinate
        )
        
        // Uniqueness is based entirely on location
        #expect(
            smithville.location.latitude == smithville4thStreet.location.latitude
        )
        #expect(
            smithville.location.longitude == smithville4thStreet.location.longitude
        )
    }
    
    // MARK: - init(from:) Tests
    
    @Test("init(from:) copies all properties") func testInitFromCopiesAllProperties() {
        let source = Landmark(
            name: "Golden Gate Bridge",
            notes: "Iconic suspension bridge",
            formattedAddress: "San Francisco, CA",
            symbol: "🌉",
            location: CLLocationCoordinate2D(latitude: 37.81985, longitude: -122.47852)
        )
        
        let copy = Landmark(from: source)
        
        #expect(copy.name == source.name)
        #expect(copy.notes == source.notes)
        #expect(copy.formattedAddress == source.formattedAddress)
        #expect(copy.symbol == source.symbol)
        #expect(copy.location.latitude == source.location.latitude)
        #expect(copy.location.longitude == source.location.longitude)
    }
    
    @Test("init(from:) produces a separate instance") func testInitFromProducesSeparateInstance() {
        let source = Landmark(name: "Eiffel Tower", notes: "Paris landmark", symbol: "🗼",
                              location: .init(latitude: 48.8584, longitude: 2.2945))
        let copy = Landmark(from: source)
        
        // They are separate objects
        #expect(copy !== source)
    }
    
    @Test("init(from:) mutations do not affect the source") func testInitFromMutationsDoNotAffectSource() {
        let source = Landmark(name: "Original Name", notes: "Original notes", symbol: "📍",
                              location: .init(latitude: 10.0, longitude: 20.0))
        let copy = Landmark(from: source)
        
        copy.name = "Modified Name"
        copy.notes = "Modified notes"
        
        #expect(source.name == "Original Name", "Mutating copy should not affect source name")
        #expect(source.notes == "Original notes", "Mutating copy should not affect source notes")
    }
    
    @Test("init(from:) handles empty fields") func testInitFromWithEmptyFields() {
        let source = Landmark(name: "", notes: "", formattedAddress: "", symbol: "",
                              location: .init(latitude: 0.0, longitude: 0.0))
        let copy = Landmark(from: source)
        
        #expect(copy.name == "")
        #expect(copy.notes == "")
        #expect(copy.formattedAddress == "")
        #expect(copy.symbol == "")
        #expect(copy.location.latitude == 0.0)
        #expect(copy.location.longitude == 0.0)
    }
    
    @Test("Inserting the same landmark twice results in one entry") func testUniqueUpsert() throws {
        
        // Set up in-memory persistence container
        let configInMemory = ModelConfiguration(
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(
            for: Landmark.self,
            configurations: configInMemory
        )
        let descriptor = FetchDescriptor<Landmark>()
        
        // Start out with no landmarks
        var allLandmarks = try container.mainContext.fetch(descriptor)
        
        #expect (
            allLandmarks.isEmpty
        )
        
        let coordinate = CLLocationCoordinate2D(
            latitude: 30.00458,
            longitude: -97.14810
        )
        let smithville = Landmark(
            name: "Smithville",
            notes: "County seat",
            formattedAddress: "Smithville, TX",
            symbol: "📍",
            location: coordinate
        )

        // Add a landmark
        container.mainContext.insert(smithville)
        allLandmarks = try container.mainContext.fetch(descriptor)

        #expect (
            allLandmarks.count == 1
        )

        // Re-add the same landmark
        container.mainContext.insert(smithville)
        allLandmarks = try container.mainContext.fetch(descriptor)

        #expect (
            allLandmarks.count == 1
        )

    }
}
