//  LocationPermissonsService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 11/13/25.
//
import MapKit

// TODO patmcg convert this to async/await?
// TODO patmcg add a mock LocationPermissionsService and use in InjectMockServicesModifier

/// A protocol to request CoreLocation permissions
protocol LocationPermissionsService {
        
    /// Requests location permissions.  The callback is called when completed.
    /// - Parameter callback: A method to call once the permissions requests completes, notifying of success or failure
    func requestPermissions(callback: @escaping (_ status: CLAuthorizationStatus) -> Void)
}

#if DEBUG
    
/// A mock implementation of `LocationPermissionsService` that always succeeds
struct AlwaysSucceedsLocationPermissionsService: LocationPermissionsService {

    func requestPermissions(callback: @escaping (CLAuthorizationStatus) -> Void) {
        callback(.authorizedWhenInUse)
    }
}

#endif
