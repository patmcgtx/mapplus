//
//  MKMapItemExtensions.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//
import MapKit

extension MKMapItem {
    
    // TODO patmcg add unit tests

    /// Generates a user-facing description of this map item, such as full address and/or place name.
    /// The result is typically a multi-line address but could be coordinates if no address is available.
    var fullDescription: String {

        // TODO patmcg use result builder

        // Start with the coordinates as a baseline        
        var 🎯 = self.location.coordinateString
        
        // Get the address info if available
        if let fullAddress = self.addressRepresentations?.fullAddress(
            includingRegion: false,
            singleLine: false) {
            🎯 = fullAddress
            if let itemName = self.name, !fullAddress.contains(itemName)  {
                🎯 = [itemName, fullAddress].joined(separator: "\n")
            }
        }
        
        return 🎯
    }
    
}
