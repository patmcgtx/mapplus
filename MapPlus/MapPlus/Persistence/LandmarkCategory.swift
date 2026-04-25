//
//  LandmarkCategory.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/21/26.
//
import SwiftData

/// Represents a grouping of landmarks, such as cafes, hotels, museums, etc.
/// Each landmark can belong to as many categories as they want (or none at all).
/// These categories are a way to filter which landmarks you see on the map.
@Model
class LandmarkCategory {
    
    /// Each category has a unique name
    #Unique<LandmarkCategory>([\.name])
    
    /// The name of the category, e.g. "Cafes"
    var name: String
    
    /// Whether this landmark is currently selected for display
    var isSelected: Bool = false
    
    /// Which landmarks are tagged with this category
    @Relationship(inverse: \Landmark.categories)
    var landmarks: [Landmark] = []
    
    /// Creates a new empty category
    /// - Parameter name: The name of the category, e.g. "Cafes"
    /// - Parameter isSelected: Whether this category is currently selected for display
    init(name: String, isSelected: Bool = false) {
        self.name = name
        self.isSelected = isSelected
    }
}

