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
            let placemark = MKPlacemark(
                coordinate: customAddress.coordinates
            )
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = customAddress.briefDescription
            return [mapItem]
        }
        
        // Try to find a matching mock address
        // Check for exact match first
        if let matchedAddress = Self.mockAddresses[searchString] {
            let placemark = MKPlacemark(
                coordinate: matchedAddress.coordinates
            )
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = matchedAddress.briefDescription
            return [mapItem]
        }
        
        // Try case-insensitive match
        let lowercaseQuery = searchString.lowercased()
        for (key, address) in Self.mockAddresses {
            if key.lowercased() == lowercaseQuery {
                let placemark = MKPlacemark(
                    coordinate: address.coordinates
                )
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = address.briefDescription
                return [mapItem]
            }
        }
        
        // Try partial match
        for (key, address) in Self.mockAddresses {
            if key.lowercased().contains(lowercaseQuery) || lowercaseQuery.contains(key.lowercased()) {
                let placemark = MKPlacemark(
                    coordinate: address.coordinates
                )
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = address.briefDescription
                return [mapItem]
            }
        }
        
        // Return a generic mock result for unknown addresses
        let defaultCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let placemark = MKPlacemark(coordinate: defaultCoordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Mock address"
        return [mapItem]
    }
}

#endif // DEBUG
