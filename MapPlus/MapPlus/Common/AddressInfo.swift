//
//  AddressInfo.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//

import CoreLocation

// TODO patmcg doc
struct AddressInfo {
    
    init(formattedDescription: String = "", latitude: CLLocationDegrees = 0.0, longitude: CLLocationDegrees = 0.0) {
        self.formattedDescription = formattedDescription
        self.latitude = latitude
        self.longitude = longitude
    }
    
    let formattedDescription: String
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
}
