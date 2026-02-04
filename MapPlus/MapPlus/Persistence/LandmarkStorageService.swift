//
//  LandmarkStorageService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/3/26.
//

import SwiftData
import CoreLocation

// TODO patmcg doc
struct LandmarkStorageService {
        
    // TODO patmcg doc
    func save(
        address: AddressInfo,
        inContext modelContext: ModelContext,
        withName name: String,
        iconName: String
    ) throws {
        
        let coord = CLLocationCoordinate2D(
            latitude: address.latitude,
            longitude: address.longitude
        )
        
        let landmark = Landmark(
            name: name,
            formattedAddress: address.formattedDescription,
            systemImageName: iconName,
            location: coord
        )
        
        modelContext.insert(landmark)
        try modelContext.save()
    }
    
}
