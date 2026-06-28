//  LocationPermissionsService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 11/13/25.
//
import MapKit

/// A protocol to request CoreLocation permissions
protocol LocationPermissionsService {
        
    /// Requests location permissions.  The callback is called when completed.
    /// - Parameter callback: A method to call once the permissions requests completes, notifying of success or failure
    func requestPermissions(callback: @escaping (_ status: CLAuthorizationStatus) -> Void)
}
