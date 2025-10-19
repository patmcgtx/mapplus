import Testing
import MapKit
@testable import MapPlus

struct LandmarkTests {
    
    @Test func testInitialization() {
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let landmark = Landmark(name: "Golden Gate", systemImageName: "bridge", location: coordinate)
        
        #expect(landmark.name == "Golden Gate")
        #expect(landmark.systemImageName == "bridge")
        #expect(landmark.location.latitude == coordinate.latitude)
        #expect(landmark.location.longitude == coordinate.longitude)
    }
    
    @Test func testUniqueness() {
        let coordinate = CLLocationCoordinate2D(latitude: 30.0, longitude: -97.0)
        let landmark1 = Landmark(name: "Domain", systemImageName: "storefront", location: coordinate)
        let landmark2 = Landmark(name: "Another", systemImageName: "circle", location: coordinate)
        
        // While different instances, uniqueness in persistence should be based on location.
        #expect(landmark1.location.latitude == landmark2.location.latitude)
        #expect(landmark1.location.longitude == landmark2.location.longitude)
    }
    
    @Test func testCoordinateComputedProperty() {
        let lat: CLLocationDegrees = 35.0
        let lon: CLLocationDegrees = -120.0
        let landmark = Landmark(name: "Test", systemImageName: "star", location: .init(latitude: lat, longitude: lon))
        
        #expect(landmark.location.latitude == lat)
        #expect(landmark.location.longitude == lon)
    }
}
