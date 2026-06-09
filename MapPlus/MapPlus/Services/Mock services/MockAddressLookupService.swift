//
//  MockAddressLookupService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/6/26.
//
import MapKit

#if DEBUG

/// A mock implementation for testing and previews.
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
        guard shouldSucceed else {
            throw MapPlusError.noAddressFound
        }
        
        // If a custom address is provided, convert it to a MKMapItem
        if let customAddress = customAddress {
            return try await createMapItem(
                from: customAddress.coordinates,
                name: customAddress.briefDescription
            )
        }
        
        // Try to find a matching mock address
        // Check for exact match first
        if let matchedAddress = Self.mockAddresses[searchString] {
            return try await createMapItem(
                from: matchedAddress.coordinates,
                name: matchedAddress.briefDescription
            )
        }
        
        // Try case-insensitive match
        let lowercaseQuery = searchString.lowercased()
        for (key, address) in Self.mockAddresses {
            if key.lowercased() == lowercaseQuery {
                return try await createMapItem(
                    from: address.coordinates,
                    name: address.briefDescription
                )
            }
        }
        
        // Try partial match
        for (key, address) in Self.mockAddresses {
            if key.lowercased().contains(lowercaseQuery) || lowercaseQuery.contains(key.lowercased()) {
                return try await createMapItem(
                    from: address.coordinates,
                    name: address.briefDescription
                )
            }
        }
        
        // Return a generic mock result for unknown addresses
        let defaultCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        return try await createMapItem(
            from: defaultCoordinate,
            name: "Mock address"
        )
    }
    
    /// Helper method to create a MKMapItem from coordinates using reverse geocoding
    private func createMapItem(from coordinate: CLLocationCoordinate2D, name: String) async throws -> [MKMapItem] {
        let location = CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        
        // Use reverse geocoding to get a proper MKMapItem
        guard let request = MKReverseGeocodingRequest(location: location) else {
            throw MapPlusError.noAddressFound
        }
        
        let mapItems = try await request.mapItems
        
        // If we got results, update the name and return
        if let firstItem = mapItems.first {
            firstItem.name = name
            return [firstItem]
        }
        
        throw MapPlusError.noAddressFound
    }
}

#endif // DEBUG
