//
//  LocationHandler.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 11/13/25.
//

import MapKit

/// TODO patmcg doc
/// TODO unit test?
class LocationHandler: NSObject, CLLocationManagerDelegate {
    
    private var locationManager = CLLocationManager()
    private var callback: (_ status: CLAuthorizationStatus) -> Void = { status in }
    
    func requestPermissions(callback: @escaping (_ status: CLAuthorizationStatus) -> Void) {
        self.callback = callback
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        callback(status)
    }
}
