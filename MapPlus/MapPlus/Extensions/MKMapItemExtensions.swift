//
//  MKMapItemExtensions.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//
import MapKit

// TODO patmcg doc
extension MKMapItem {
    
    // TODO patmcg doc
    // TODO patmcg add unit tests
    var fullDescription: String {
        
        var retval = MapPlusError.noAddressFound.errorMessage
        
        if let fullAddress = self.addressRepresentations?.fullAddress(includingRegion: false, singleLine: false) {
            retval = fullAddress
            if let itemName = self.name, !fullAddress.contains(itemName)  {
                retval = [itemName, fullAddress].joined(separator: "\n")
            }
        }
        
        return retval
    }
    
}
