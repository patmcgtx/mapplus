//
//  MockLookAroundService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/15/26.
//
import MapKit

/// A mock implementation of LookAroundService for testing and previews.
/// Returns predefined look-around scenes or throws errors based on configuration.
struct MockLookAroundService: LookAroundService {
    
    /// Controls whether the mock should simulate a successful lookup or throw an error.
    var shouldSucceed: Bool = true
    
    /// Controls whether the mock should return a scene (true) or nil (false) when successful.
    var sceneAvailable: Bool = true
    
    /// Optional custom scene to return instead of using the default behavior.
    var customScene: MKLookAroundScene?
    
    /// A collection of predefined mock coordinates where look-around should be available.
    static let mockAvailableLocations: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // San Francisco
        CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),  // New York
        CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),   // London
        CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),  // Tokyo
        CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090)  // Cupertino
    ]
    
    /// Gets a mock look-around scene for a given location.
    /// - Parameter location: Which coordinate to get the look-around for
    /// - Returns: A look-around scene object for the location or `nil` if none is available
    /// - Throws: An error if shouldSucceed is false
    func lookAroundScene(for location: CLLocationCoordinate2D) async throws -> MKLookAroundScene? {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        if !shouldSucceed {
            throw MapPlusError.noAddressFound
        }
        
        if let customScene = customScene {
            return customScene
        }
        
        // If sceneAvailable is false, return nil
        if !sceneAvailable {
            return nil
        }
        
        // Check if the location is in our predefined available locations
        let isLocationAvailable = Self.mockAvailableLocations.contains { mockLocation in
            // Consider locations within ~0.01 degrees as matching
            abs(mockLocation.latitude - location.latitude) < 0.01 &&
            abs(mockLocation.longitude - location.longitude) < 0.01
        }
        
        if isLocationAvailable {
            // Create a mock scene request and return the scene
            // Note: In real tests, we can't create actual MKLookAroundScene objects,
            // so we'll return nil to simulate "scene not available" for non-matching locations
            // The actual scene creation would need to be tested with real MapKit
            return nil // Placeholder - actual scene creation requires MapKit
        }
        
        return nil
    }
}
