//
//  MockAddressLookupService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/6/26.
//
import Foundation

#if DEBUG

// TODO patmcg cleanup?

/// A mock implementation of AddressLookupProtocol for testing and previews.
/// Returns predefined addresses or throws errors based on the input.
/// (Thanks, Claude Sonnet.)
struct MockAddressLookupService: AddressLookupService {
    
    /// Controls whether the mock should simulate a successful lookup or throw an error.
    var shouldSucceed: Bool = true
    
    /// Optional custom address to return instead of using the default mock data.
    var customAddress: LocationInfo?
    
    /// A collection of predefined mock addresses for common test scenarios.
    static let mockAddresses: [String: LocationInfo] = [
        "San Francisco": LocationInfo(
            briefDescription: "San Fransisco",
            fullDescription: "San Francisco, CA, United States",
            latitude: 37.7749,
            longitude: -122.4194
        ),
        "New York": LocationInfo(
            briefDescription: "NYC",
            fullDescription: "New York, NY, United States",
            latitude: 40.7128,
            longitude: -74.0060
        ),
        "London": LocationInfo(
            briefDescription: "London",
            fullDescription: "London, United Kingdom",
            latitude: 51.5074,
            longitude: -0.1278
        ),
        "Tokyo": LocationInfo(
            briefDescription: "Tokyo",
            fullDescription: "Tokyo, Japan",
            latitude: 35.6762,
            longitude: 139.6503
        ),
        "1 Infinite Loop": LocationInfo(
            briefDescription: "Apple HQ",
            fullDescription: "1 Infinite Loop, Cupertino, CA 95014, United States",
            latitude: 37.3349,
            longitude: -122.0090
        )
    ]
    
    /// Performs a mock address lookup.
    /// - Parameter address: The address string to look up.
    /// - Returns: A mock AddressInfo object.
    /// - Throws: MapPlusError.noAddressFound if shouldSucceed is false or address is not in mock data.
    func lookup(address: String) async throws -> LocationInfo {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        if !shouldSucceed {
            throw MapPlusError.noAddressFound
        }
        
        if let customAddress = customAddress {
            return customAddress
        }
        
        // Try to find an exact match first
        if let mockAddress = Self.mockAddresses[address] {
            return mockAddress
        }
        
        // Try case-insensitive partial match
        if let match = Self.mockAddresses.first(where: { key, _ in
            key.localizedCaseInsensitiveContains(address) || address.localizedCaseInsensitiveContains(key)
        }) {
            return match.value
        }
        
        // Return a generic address for any other query
        return LocationInfo(
            briefDescription: "Mock address",
            fullDescription: "\(address) (Mock Result)",
            latitude: 37.7749,
            longitude: -122.4194
        )
    }
}

#endif // DEBUG
