//
//  LandmarkCategory.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/21/26.
//
import SwiftData
import Foundation

/// Represents a grouping of landmarks, such as cafes, hotels, museums, etc.
/// Each landmark can belong to as many categories as they want (or none at all).
/// These categories are a way to filter which landmarks you see on the map.
@Model
class LandmarkCategory {
    
    /// Each category has a unique name
    #Unique<LandmarkCategory>([\.name])
    
    /// A stable identifier that persists even if the category name changes
    var id: UUID
    
    /// The name of the category, e.g. "Cafes"
    var name: String
    
    /// Which landmarks are tagged with this category
    @Relationship(inverse: \Landmark.categories)
    var landmarks: [Landmark] = []
    
    /// Creates a new empty category
    /// - Parameter name: The name of the category, e.g. "Cafes"
    /// - Parameter id: A stable identifier (auto-generated if not provided)
    init(name: String, id: UUID = UUID()) {
        self.id = id
        self.name = name
    }
}

