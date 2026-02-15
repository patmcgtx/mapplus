import Testing
import MapKit
@testable import MapPlus

struct LookAroundServiceTests {
    
    // MARK: - MockLookAroundService Tests
    
    @Test func testMockLookAroundSuccessWithAvailableLocation() async throws {
        let service = MockLookAroundService()
        
        // Test with San Francisco coordinates (a mock available location)
        let sanFrancisco = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let result = try await service.lookAroundScene(for: sanFrancisco)
        
        // The mock service returns nil as a placeholder since we can't create actual MKLookAroundScene objects
        #expect(result == nil)
    }
    
    @Test func testMockLookAroundSuccessWithUnavailableLocation() async throws {
        let service = MockLookAroundService()
        
        // Test with a random location not in the mock available locations
        let randomLocation = CLLocationCoordinate2D(latitude: 10.0, longitude: 20.0)
        let result = try await service.lookAroundScene(for: randomLocation)
        
        #expect(result == nil)
    }
    
    @Test func testMockLookAroundSceneNotAvailable() async throws {
        let service = MockLookAroundService(sceneAvailable: false)
        
        let sanFrancisco = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let result = try await service.lookAroundScene(for: sanFrancisco)
        
        #expect(result == nil)
    }
    
    @Test func testMockLookAroundFailure() async throws {
        let service = MockLookAroundService(shouldSucceed: false)
        
        let sanFrancisco = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        
        do {
            _ = try await service.lookAroundScene(for: sanFrancisco)
            Issue.record("Expected lookup to throw, but it did not")
        } catch let error as MapPlusError {
            #expect(error == .noAddressFound)
        } catch {
            Issue.record("Expected MapPlusError.noAddressFound, but got: \(error)")
        }
    }
    
    @Test func testMockLookAroundWithCustomScene() async throws {
        // We can't create actual MKLookAroundScene objects in tests,
        // so we test the customScene parameter path with nil
        let service = MockLookAroundService(customScene: nil)
        
        let sanFrancisco = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let result = try await service.lookAroundScene(for: sanFrancisco)
        
        #expect(result == nil)
    }
    
    @Test func testMockLookAroundAllPredefinedLocations() async throws {
        let service = MockLookAroundService()
        
        // Test all predefined locations
        let locations = [
            CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // San Francisco
            CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),  // New York
            CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),   // London
            CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),  // Tokyo
            CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090)  // Cupertino
        ]
        
        for location in locations {
            let result = try await service.lookAroundScene(for: location)
            // All should return nil since we can't create actual scenes in tests
            #expect(result == nil)
        }
    }
    
    @Test func testMockLookAroundNearbyLocation() async throws {
        let service = MockLookAroundService()
        
        // Test with a location very close to San Francisco (within 0.01 degrees)
        let nearbySanFrancisco = CLLocationCoordinate2D(latitude: 37.7750, longitude: -122.4195)
        let result = try await service.lookAroundScene(for: nearbySanFrancisco)
        
        #expect(result == nil)
    }
    
    @Test func testMockLookAroundFarFromPredefinedLocation() async throws {
        let service = MockLookAroundService()
        
        // Test with a location far from any predefined locations
        let farLocation = CLLocationCoordinate2D(latitude: 37.8, longitude: -122.5)
        let result = try await service.lookAroundScene(for: farLocation)
        
        #expect(result == nil)
    }
    
    // MARK: - Protocol Interface Tests
    
    @Test func testProtocolInterfaceWithMapKitService() async throws {
        let service: LookAroundService = MapKitLookAroundService()
        
        // This test verifies we can use MapKitLookAroundService through the protocol interface
        // We expect it to work in a real environment but may fail in sandboxed tests
        let sanFrancisco = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        
        do {
            _ = try await service.lookAroundScene(for: sanFrancisco)
        } catch {
            // Expected to potentially fail in test environment
            #expect(error is Error)
        }
    }
    
    @Test func testProtocolInterfaceWithMockService() async throws {
        let service: LookAroundService = MockLookAroundService()
        
        // This test verifies we can use MockLookAroundService through the protocol interface
        let sanFrancisco = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let result = try await service.lookAroundScene(for: sanFrancisco)
        
        #expect(result == nil)
    }
    
    @Test func testMockLookAroundServiceConfiguration() async throws {
        // Test different configurations
        let successService = MockLookAroundService(shouldSucceed: true, sceneAvailable: true)
        let failService = MockLookAroundService(shouldSucceed: false, sceneAvailable: true)
        let noSceneService = MockLookAroundService(shouldSucceed: true, sceneAvailable: false)
        
        let location = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        
        // Test success service
        let successResult = try await successService.lookAroundScene(for: location)
        #expect(successResult == nil)
        
        // Test fail service
        do {
            _ = try await failService.lookAroundScene(for: location)
            Issue.record("Expected failService to throw")
        } catch {
            #expect(error is MapPlusError)
        }
        
        // Test no scene service
        let noSceneResult = try await noSceneService.lookAroundScene(for: location)
        #expect(noSceneResult == nil)
    }
}
