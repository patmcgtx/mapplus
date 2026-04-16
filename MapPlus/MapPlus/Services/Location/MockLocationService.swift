//
//  MockCurrentLocationService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/12/26.
//
import CoreLocation

#if DEBUG

// TODO patmcg cleanup docs

/// A mock implementation of LocationService for testing and previews.
/// Returns a predefined location or throws errors based on configuration.
/// (Thanks, Claude Sonnet.)
class MockLocationService: LocationService {
    
    // TODO patmcg simplify like MockLookAroundService

    /// Controls whether the mock should simulate a successful location fetch or throw an error.
    var shouldSucceed: Bool = true
    
    /// Optional custom address to return instead of using the default mock data.
    var customAddress: LocationInfo?
    
    /// Gets a mock current location.
    /// - Returns: A mock AddressInfo object.
    /// - Throws: MapPlusError.noAddressFound if shouldSucceed is false.
    func getCurrentLocation() async throws -> LocationInfo {
        // Simulate network/location delay
        try await Task.sleep(for: .seconds(5))
        
        if !shouldSucceed {
            throw MapPlusError.noAddressFound
        }
        
        if let customAddress = customAddress {
            return customAddress
        }
        
        // Return a default mock current location (San Francisco)
        return LocationInfo(
            briefDescription: "Mock SF",
            fullDescription: "(Mock) San Francisco, CA, United States",
            latitude: 37.7749,
            longitude: -122.4194
        )
    }
}

#endif // DEBUG
