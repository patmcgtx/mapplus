//
//  LandmarkExtensions.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/16/26.
//
import CoreLocation
import MapKit

/// Helpful extensions to the Landmark persistent type.
extension Landmark {
    
    /// Opens this landmark in the  Maps app, for a full-featured maps experience,
    /// for example to get directions, search, or see surrounding businesses.
    func openInMaps(mapsOptions: [String : Any]? = [:]) {

        let loc = CLLocation(
            latitude: self.location.latitude,
            longitude: self.location.longitude
        )
        let mapItem = MKMapItem(location: loc, address: nil)

        mapItem.name = self.name
        mapItem.openInMaps(launchOptions: mapsOptions)
    }
    
}
