//
//  MKMapItemExtensions.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//
import MapKit

// TODO patmcg doc
// TODO patmcg unit test
// TODO patmcg use result builder
extension MKMapItem {
    
    var fullDescription: String {

        var retval = [
            self.location.coordinate.latitude.description,
            self.location.coordinate.longitude.description
        ].joined(separator: ",")
        
        if let rep = self.addressRepresentations {
                        
            if let fullAddress = rep.fullAddress(includingRegion: false, singleLine: false) {
                retval = fullAddress
                if let itemName = self.name, !fullAddress.contains(itemName)  {
                    retval = [itemName, fullAddress].joined(separator: "\n")
                }
            }
            
        }
        
        return retval
    }
    
}
