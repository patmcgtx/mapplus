import Testing
import MapKit
import SwiftData
@testable import MapPlus

struct LandmarkTests {
    
    // Test data for parameterized landmark initialization tests
    struct LandmarkTestCase {
        let name: String
        let notes: String
        let formattedAddress: String
        let systemImageName: String
        let latitude: CLLocationDegrees
        let longitude: CLLocationDegrees
        let description: String
    }
    
    @Test("Landmark initialization", arguments: [
        LandmarkTestCase(
            name: "Golden Gate Bridge",
            notes: "bridge",
            formattedAddress: "San Francisco, CA",
            systemImageName: "bridge",
            latitude: 37.81985,
            longitude: -122.47852,
            description: "Golden Gate Bridge"
        ),
        LandmarkTestCase(
            name: "Sunny Beach Pocket Park",
            notes: "Nice small beach with amenities",
            formattedAddress: "123 Beach Rd, Sunnyville",
            systemImageName: "beach.umbrella",
            latitude: 29.23755,
            longitude: -94.87794,
            description: "Beach park"
        ),
        LandmarkTestCase(
            name: "Smithville",
            notes: "",
            formattedAddress: "Smithville, TX",
            systemImageName: "mappin.circle",
            latitude: 30.00458,
            longitude: -97.14810,
            description: "Smithville"
        ),
        LandmarkTestCase(
            name: "Central Park",
            notes: "Large urban park",
            formattedAddress: "New York, NY",
            systemImageName: "tree",
            latitude: 40.785091,
            longitude: -73.968285,
            description: "Central Park"
        ),
        LandmarkTestCase(
            name: "Empty Notes Location",
            notes: "",
            formattedAddress: "Test Address",
            systemImageName: "mappin",
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
            systemImageName: testCase.systemImageName,
            location: coordinate
        )
        
        #expect(landmark.name == testCase.name,
                "Expected name '\(testCase.name)' for \(testCase.description)")
        #expect(landmark.notes == testCase.notes,
                "Expected notes '\(testCase.notes)' for \(testCase.description)")
        #expect(landmark.formattedAddress == testCase.formattedAddress,
                "Expected address '\(testCase.formattedAddress)' for \(testCase.description)")
        #expect(landmark.systemImageName == testCase.systemImageName,
                "Expected image name '\(testCase.systemImageName)' for \(testCase.description)")
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
            systemImageName: "mappin",
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
    
    @Test func testUniqueness() {
        
        let coordinate = CLLocationCoordinate2D(
            latitude: 30.00458,
            longitude: -97.14810
        )
        let smithville = Landmark(
            name: "Smithville",
            notes: "",
            formattedAddress: "Smithville, TX",
            systemImageName: "mappin.circle",
            location: coordinate
        )
        let smithville4thStreet = Landmark(
            name: "4th Street",
            notes: "",
            formattedAddress: "4th St, Smithville, TX",
            systemImageName: "mappin",
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
    
    @MainActor @Test func testUniqueUpsert() throws {
        
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
            systemImageName: "mappin.circle",
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
