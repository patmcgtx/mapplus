//
//  MKMapItemExtensions.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//
import MapKit

// TODO patmcg doc
// TODO patmcg unit test 
extension MKMapItem {
    
    var fullDescription: String {
        
        var retval = MapPlusError.addressNotFound.localizedDescription
        
        if let fullAddress = self.addressRepresentations?.fullAddress(includingRegion: false, singleLine: false) {
            retval = fullAddress
            if let itemName = self.name, !fullAddress.contains(itemName)  {
                retval = [itemName, fullAddress].joined(separator: "\n")
            }
        }
        
        return retval
    }
    
}
