//
//  PlacemarkExtentions.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//
import CoreLocation
import Contacts

// TODO patmcg add unit tests
extension CLPlacemark {
    
    var formattedAddress: String? {
    
        guard let postalAddress = postalAddress else { return nil }
        
        let formatter = CNPostalAddressFormatter()
        return formatter.string(from: postalAddress)
    }
}
