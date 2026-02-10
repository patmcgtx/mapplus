import Testing
import MapKit
import SwiftData
@testable import MapPlus

struct LandmarkTests {
    
    @Test func testInitialization() {
        
        let coordinate = CLLocationCoordinate2D(
            latitude: 37.81985,
            longitude: -122.47852
        )
        let goldenGate = Landmark(
            name: "Golden Gate Bridge",
            notes: "bridge",
            formattedAddress: "San Francisco, CA",
            systemImageName: "bridge",
            location: coordinate
        )
        
        #expect(
            goldenGate.name == "Golden Gate Bridge"
        )
        #expect(
            goldenGate.systemImageName == "bridge"
        )
        #expect(
            goldenGate.location.latitude == coordinate.latitude
        )
        #expect(
            goldenGate.location.longitude == coordinate.longitude
        )
    }

    @Test func testCoordinateComputedProperty() {
        
        let lat: CLLocationDegrees = 29.23755
        let lon: CLLocationDegrees = -94.87794
        let beachPark = Landmark(
            name: "Sunny Beach Pocket Park",
            notes: "Nice small beach with amenities",
            formattedAddress: "123 Beach Rd, Sunnyville",
            systemImageName: "beach.umbrella",
            location: .init(
                latitude: lat,
                longitude: lon
            )
        )
        
        #expect(
            beachPark.location.latitude == lat
        )
        #expect(
            beachPark.location.longitude == lon
        )
    }
    
    @Test func testUniqueness() {
        
        let coordinate = CLLocationCoordinate2D(
            latitude: 30.00458,
            longitude: -97.14810
        )
        let swmithville = Landmark(
            name: "Smithville",
            notes: "",
            formattedAddress: "Smithville, TX",
            systemImageName: "mappin.circle",
            location: coordinate
        )
        let swmithville4thStreet = Landmark(
            name: "4th Street",
            notes: "",
            formattedAddress: "4th St, Smithville, TX",
            systemImageName: "mappin",
            location: coordinate
        )
        
        // Uniqueness is based entirely on location
        #expect(
            swmithville.location.latitude == swmithville4thStreet.location.latitude
        )
        #expect(
            swmithville.location.longitude == swmithville4thStreet.location.longitude
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
