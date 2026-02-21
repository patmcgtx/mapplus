//
//  LandmarkStorageService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/3/26.
//

import SwiftData
import CoreLocation

/// A persistent store for a specific managed landmark.
struct LandmarkStore {

    /// The landmark object to manage
    let landmark: Landmark

    /// The context under which to perform persistence operations
    let modelContext: ModelContext
    
    /// Updates the managed landmark with any provided  non-nil values and commits the changes.
    /// The landmark will be updated in place (if it already exists) or inserted into the store.
    /// Any nil or excluded values are ignored.
    func upsertAndCommit(
        name: String? = nil,
        notes: String? = nil,
        formattedAddress: String? = nil,
        systemImageName: String? = nil,
        location: CLLocationCoordinate2D? = nil
    ) throws {
        if let newName = name { landmark.name = newName }
        if let newNotes = notes { landmark.notes = newNotes }
        if let newFormattedAddress = formattedAddress { landmark.formattedAddress = newFormattedAddress }
        if let newSystemImageName = systemImageName { landmark.systemImageName = newSystemImageName }
        if let newLocation = location {
            landmark.latitude = newLocation.latitude
            landmark.longitude = newLocation.longitude
        }
        
        modelContext.insert(landmark)
        try modelContext.save()
    }
    
    /// Deletes the managed Landmark and commits the change.
    /// - Throws: Re-throws any error encountered when saving the `modelContext`.
    func deleteAndCommit() throws {
        self.modelContext.delete(landmark)
        try modelContext.save()
    }
}
