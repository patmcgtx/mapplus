//
//  LocationPermissonsService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 11/13/25.
//

import MapKit

/// TODO patmcg doc
class LocationPermissonsService: NSObject, CLLocationManagerDelegate {
    
    private var locationManager = CLLocationManager()
    private var callback: (_ status: CLAuthorizationStatus) -> Void = { status in }
    
    /// Requests "when in use" location permissions as needed
    /// - Parameter callback : A closure to call when the permissions request completes
    func requestPermissions(callback: @escaping (_ status: CLAuthorizationStatus) -> Void) {
        self.callback = callback
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
    }

    // TODO patmcg is this used/needed?
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        callback(status)
    }
}
