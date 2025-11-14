//
//  LocationHandler.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 11/13/25.
//

import MapKit

class LocationHandler: NSObject, CLLocationManagerDelegate {
    
    private var locationManager = CLLocationManager()
    
    func requestPermissions() {
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
    }

    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        print("TODO patmcg need to do anyting?  Need this method?")
    }
}
