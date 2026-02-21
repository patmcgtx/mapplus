//
//  LandmarkStorageService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/3/26.
//

import SwiftData
import CoreLocation

// TODO patmcg clean up these comments

/// A lightweight service responsible for persisting `Landmark` models
/// using SwiftData. This type provides convenience helpers to translate
/// app-level types (like `LocationInfo`) into persisted `Landmark` records.
struct LandmarkStorageService {
        
    /// The context under which to perform persistence operations
    let modelContext: ModelContext
    
    /// Saves a new `Landmark` and commits the change.
    ///
    /// This method converts the supplied `LocationInfo` into a `CLLocationCoordinate2D`
    /// and constructs a `Landmark` with the given name and system image. The new
    /// landmark is inserted into the context and the context is saved.
    ///
    /// - Parameters:
    ///   - location: The location information that provides the latitude, longitude,
    ///              and formatted description for the landmark.
    ///   - name: The display name to assign to the landmark.
    ///   - notes: Descriptive notes about the landmark.
    ///   - iconName: The SF Symbols system image name associated with the landmark.
    /// - Throws: Re-throws any error encountered when saving the `modelContext`.
    // TODO patmcg unit tests
    func save(location: LocationInfo,
              name: String,
              notes: String,
              iconName: String) throws {
        
        let landmark = Landmark(
            name: name,
            notes: notes,
            formattedAddress: location.formattedDescription,
            systemImageName: iconName,
            location: location.coordinates
        )
        
        self.modelContext.insert(landmark)
        try modelContext.save()
    }
    
    /// Deletes the given `Landmark` and commits the change.
    /// - Parameters:
    ///   - landmark: The landmark to delete
    /// - Throws: Re-throws any error encountered when saving the `modelContext`.
    // TODO patmcg unit tests
    func delete(landmark: Landmark) throws {
        self.modelContext.delete(landmark)
        try modelContext.save()
    }
    
    // TODO patmcg doc
    // TODO patmcg unit tests
    func remove(category: LandmarkCategory,
                from landmark: Landmark) throws {
        let updatedCategories = landmark.categories.filter {
            $0.id != category.id
        }
        landmark.categories = updatedCategories
        try modelContext.save()
    }
}
