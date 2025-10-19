import Testing
import MapKit
@testable import MapPlus

struct LandmarkTests {
    
    @Test func testInitialization() {
        
        let coordinate = CLLocationCoordinate2D(latitude: 37.81985, longitude: -122.47852)
        let landmark = Landmark(name: "Golden Gate Bridge", systemImageName: "bridge", location: coordinate)
        
        #expect(landmark.name == "Golden Gate Bridge")
        #expect(landmark.systemImageName == "bridge")
        #expect(landmark.location.latitude == coordinate.latitude)
        #expect(landmark.location.longitude == coordinate.longitude)
    }

    @Test func testCoordinateComputedProperty() {
        
        let lat: CLLocationDegrees = 35.0
        let lon: CLLocationDegrees = -120.0
        let landmark = Landmark(name: "Some landmark", systemImageName: "microphone", location: .init(latitude: lat, longitude: lon))
        
        #expect(landmark.location.latitude == lat)
        #expect(landmark.location.longitude == lon)
    }
    
    @Test func testUniqueness() {
        
        let coordinate = CLLocationCoordinate2D(latitude: 30.0, longitude: -97.0)
        let landmark = Landmark(name: "A Landmark", systemImageName: "mappin", location: coordinate)
        let samePlace = Landmark(name: "Same Landmark", systemImageName: "mappin.circle", location: coordinate)
        
        // Uniqueness is based entirely on location (other attribues become an upsert in SwiftData)
        #expect(landmark.location.latitude == samePlace.location.latitude)
        #expect(landmark.location.longitude == samePlace.location.longitude)
    }
}
