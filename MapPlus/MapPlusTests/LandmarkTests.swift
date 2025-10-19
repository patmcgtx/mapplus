import Testing
import MapKit
@testable import MapPlus

struct LandmarkTests {
    
    @Test func testInitialization() {
        
        let coordinate = CLLocationCoordinate2D(
            latitude: 37.81985,
            longitude: -122.47852
        )
        let goldenGate = Landmark(
            name: "Golden Gate Bridge",
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
            systemImageName: "mappin.circle",
            location: coordinate
        )
        let swmithville4thStreet = Landmark(
            name: "4th Street",
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
    
}
