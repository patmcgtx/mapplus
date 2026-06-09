//
//  MapKitLocationPermissionsService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 6/9/26.
//
import MapKit

/// Service that wraps CLLocationManager to request and report location authorization status.
class MapKitLocationPermissionsService: NSObject, CLLocationManagerDelegate, LocationPermissionsService {
    
    private var locationManager = CLLocationManager()
    private var callback: (_ status: CLAuthorizationStatus) -> Void = { _ in }

    /// Requests "when in use" location permissions as needed.
    func requestPermissions(callback: @escaping (_ status: CLAuthorizationStatus) -> Void) {
        self.callback = callback
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
    }

    // MARK: - CLLocationManagerDelegate

    /// Forward authorization changes from the CLLocationManager to the stored callback.
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        callback(status)
    }
}
