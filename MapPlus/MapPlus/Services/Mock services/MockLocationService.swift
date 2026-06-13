//
//  MockCurrentLocationService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/12/26.
//
import CoreLocation
import MapKit

#if DEBUG

/// A mock implementation for testing and previews.
class MockLocationService: LocationService {    
    
    // TODO add an initializer and use in InjectMockServicesModifier or for previews 
    
    // TODO patmcg implement
    func nearbyMapItems() async throws -> [MKMapItem] {
        return []
    }

    /// Controls how long to delay before return mock results
    var delaySeconds: Double = 0.0

    /// Controls whether the mock should simulate a successful location fetch or throw an error.
    var shouldSucceed: Bool = true
    
    /// Optional custom address to return instead of using the default mock data.
    var customAddress: LocationInfo?
}

#endif // DEBUG
