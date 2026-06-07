//
//  MockAddressLookupService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/6/26.
//
import MapKit

#if DEBUG

/// A mock implementation of `AddressLookupService` for testing and previews.
struct MockAddressLookupService: AddressLookupService {
        
    /// Controls whether the mock should simulate a successful lookup or throw an error.
    var shouldSucceed: Bool = true
    
    /// Optional custom address to return instead of using the default mock data.
    var customAddress: LocationInfo?
    
    /// A collection of predefined mock addresses for common test scenarios.
    static let mockAddresses: [String: LocationInfo] = [
        "San Francisco": LocationInfo(
            briefDescription: "San Francisco",
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
    
    func mapItemsFor(searchString: String) async throws -> [MKMapItem] {
        // TODO patmcg impl
        return []
    }
}

#endif // DEBUG
