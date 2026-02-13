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
        
        // TODO patmcg user result builder
        
        // TODO patmcg move this logic to a CLLocation extension
        var retval = [
            // Format lat & long o  decimal places, just like  Maps
            String(format: "%.5f", self.location.coordinate.latitude),
            String(format: "%.5f", self.location.coordinate.longitude),
        ]
            .joined(separator: ", ")
        
        if let fullAddress = self.addressRepresentations?.fullAddress(
            includingRegion: false,
            singleLine: false
        ) {
            retval = fullAddress
            if let itemName = self.name, !fullAddress.contains(itemName)  {
                retval = [itemName, fullAddress].joined(separator: "\n")
            }
        }
        
        return retval
    }
    
}
