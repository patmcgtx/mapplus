//
//  LandmarkExtensions.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/16/26.
//
import CoreLocation
import MapKit

extension Landmark {
    
    // TODO patmcg doc
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
