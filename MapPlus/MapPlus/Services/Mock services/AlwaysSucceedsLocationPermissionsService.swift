//
//  AlwaysSucceedsLocationPermissionsService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 6/13/26.
//

#if DEBUG

import MapKit

/// A mock implementation of `LocationPermissionsService` that always succeeds
struct AlwaysSucceedsLocationPermissionsService: LocationPermissionsService {

    func requestPermissions(callback: @escaping (CLAuthorizationStatus) -> Void) {
        callback(.authorizedWhenInUse)
    }
}

#endif // DEBUG
