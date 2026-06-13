//
//  MockCurrentLocationService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/12/26.
//
import CoreLocation
import MapKit
import Contacts

#if DEBUG

/// A mock implementation for testing and previews.
class MockLocationService: LocationService {    
    
    func nearbyMapItems() async throws -> [MKMapItem] {
        
        // Apply delay if configured
        if delaySeconds > 0 {
            try await Task.sleep(for: .seconds(delaySeconds))
        }
        
        // Simulate error if configured
        guard shouldSucceed else {
            throw MapPlusError.noLocationInfo
        }
        
        // Convert LocationInfo items to MKMapItem
        return customAddresses.map { locationInfo in
            let placemark = MKPlacemark(
                coordinate: locationInfo.coordinates,
                addressDictionary: [
                    CNPostalAddressStreetKey: locationInfo.fullDescription
                ]
            )
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = locationInfo.briefDescription
            return mapItem
        }
    }

    /// Controls how long to delay before return mock results
    var delaySeconds: Double = 0.0

    /// Controls whether the mock should simulate a successful location fetch or throw an error.
    var shouldSucceed: Bool = true
    
    /// Optional custom address to return instead of using the default mock data.
    var customAddresses: [LocationInfo] = []
}

#endif // DEBUG
