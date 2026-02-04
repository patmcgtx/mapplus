//
//  LandmarkStorageService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/3/26.
//

import SwiftData
import CoreLocation

/// A lightweight service responsible for persisting `Landmark` models
/// using SwiftData. This type provides convenience helpers to translate
/// app-level types (like `AddressInfo`) into persisted `Landmark` records.
struct LandmarkStorageService {
    
    // TODO patmcg initialize with modelContext: ModelContext
        
    /// Saves a new `Landmark` to the provided SwiftData `ModelContext`.
    ///
    /// This method converts the supplied `AddressInfo` into a `CLLocationCoordinate2D`
    /// and constructs a `Landmark` with the given name and system image. The new
    /// landmark is inserted into the context and the context is saved.
    ///
    /// - Parameters:
    ///   - address: The address information that provides the latitude, longitude,
    ///              and formatted description for the landmark.
    ///   - modelContext: The SwiftData model context used to insert and persist the
    ///                   new `Landmark`.
    ///   - withName: The display name to assign to the landmark.
    ///   - iconName: The SF Symbols system image name associated with the landmark.
    /// - Throws: Rethrows any error encountered when saving the `modelContext`.
    func save(
        address: AddressInfo,
        // TODO patmchg would be nice to find its own modelContext
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
