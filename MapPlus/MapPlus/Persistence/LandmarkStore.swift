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

    /// The context under which to perform persistence operations
    let modelContext: ModelContext
    
    /// Updates the managed landmark with any provided  non-nil values and commits the changes.
    /// The landmark will be updated in place (if it already exists) or inserted into the store.
    /// Any nil or excluded values are ignored.
    func commit(landmark: Landmark) throws {
        modelContext.insert(landmark)
        try modelContext.save()
    }
    
    /// Deletes the managed Landmark and commits the change.
    /// - Throws: Re-throws any error encountered when saving the `modelContext`.
    func delete(landmark: Landmark) throws {
        self.modelContext.delete(landmark)
        try modelContext.save()
    }
}
