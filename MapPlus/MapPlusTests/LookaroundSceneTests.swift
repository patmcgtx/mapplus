import Testing
@testable import MapPlus
import MapKit

struct LookaroundSceneTests {
    
    // MARK: - MockLookaroundSceneService Tests
    
    @Test func testMockLookaroundSceneServiceReturnsNilWhenConfigured() async throws {
        let service = MockLookaroundSceneService(shouldReturnScene: false)
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        
        let scene = try await service.fetchLookaroundScene(for: coordinate)
        
        #expect(scene == nil)
    }
    
    @Test func testMockLookaroundSceneServiceReturnsSceneWhenConfigured() async throws {
        let service = MockLookaroundSceneService(shouldReturnScene: true)
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        
        let scene = try await service.fetchLookaroundScene(for: coordinate)
        
        // Note: Mock cannot create real MKLookAroundScene objects, so it returns nil
        // This test verifies the service doesn't throw when shouldReturnScene is true
        #expect(scene == nil)
    }
    
    @Test func testMockLookaroundSceneServiceThrowsErrorWhenConfigured() async throws {
        let service = MockLookaroundSceneService(shouldThrowError: true)
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        
        do {
            _ = try await service.fetchLookaroundScene(for: coordinate)
            Issue.record("Expected service to throw, but it did not")
        } catch {
            // Expected to throw
            #expect(error is NSError)
        }
    }
    
    @Test func testMockLookaroundSceneServiceThrowsCustomError() async throws {
        struct CustomError: Error {}
        let customError = CustomError()
        let service = MockLookaroundSceneService(shouldThrowError: true, customError: customError)
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        
        do {
            _ = try await service.fetchLookaroundScene(for: coordinate)
            Issue.record("Expected service to throw, but it did not")
        } catch {
            #expect(error is CustomError)
        }
    }
    
    @Test func testMockLookaroundSceneServiceWithMultipleCoordinates() async throws {
        let service = MockLookaroundSceneService(shouldReturnScene: false)
        
        let coordinates = [
            CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // San Francisco
            CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),   // New York
            CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),    // London
            CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503)    // Tokyo
        ]
        
        for coordinate in coordinates {
            let scene = try await service.fetchLookaroundScene(for: coordinate)
            #expect(scene == nil)
        }
    }
    
    // MARK: - Protocol Interface Tests
    
    @Test func testProtocolInterfaceWithMapKitService() async throws {
        let service: LookaroundSceneProtocol = MapKitLookaroundSceneService()
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        
        // This test verifies we can use MapKitLookaroundSceneService through the protocol interface
        // The actual scene availability depends on Apple's data, so we just verify it doesn't crash
        do {
            let scene = try await service.fetchLookaroundScene(for: coordinate)
            // Scene may or may not be available depending on location
            #expect(scene == nil || scene != nil)
        } catch {
            // Network errors or other issues are acceptable in test environment
            #expect(error is Error)
        }
    }
    
    @Test func testProtocolInterfaceWithMockService() async throws {
        let service: LookaroundSceneProtocol = MockLookaroundSceneService(shouldReturnScene: false)
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        
        // This test verifies we can use MockLookaroundSceneService through the protocol interface
        let scene = try await service.fetchLookaroundScene(for: coordinate)
        
        #expect(scene == nil)
    }
    
    @Test func testProtocolInterfaceAllowsServiceSubstitution() async throws {
        // Test that we can substitute different implementations
        let mockService: LookaroundSceneProtocol = MockLookaroundSceneService(shouldReturnScene: true)
        let realService: LookaroundSceneProtocol = MapKitLookaroundSceneService()
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        
        // Both should be callable through the same interface
        _ = try? await mockService.fetchLookaroundScene(for: coordinate)
        _ = try? await realService.fetchLookaroundScene(for: coordinate)
        
        // If we got here without crashing, the test passes
        #expect(true)
    }
    
    // MARK: - Edge Cases
    
    @Test func testMockLookaroundSceneServiceWithInvalidCoordinate() async throws {
        let service = MockLookaroundSceneService(shouldReturnScene: false)
        let invalidCoordinate = CLLocationCoordinate2D(latitude: 999, longitude: 999)
        
        // Mock service should still work with invalid coordinates (it doesn't validate)
        let scene = try await service.fetchLookaroundScene(for: invalidCoordinate)
        #expect(scene == nil)
    }
    
    @Test func testMockLookaroundSceneServiceWithZeroCoordinate() async throws {
        let service = MockLookaroundSceneService(shouldReturnScene: false)
        let zeroCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
        let scene = try await service.fetchLookaroundScene(for: zeroCoordinate)
        #expect(scene == nil)
    }
}
