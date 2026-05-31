//
//  SelectedCategories.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 5/30/26.
//
import SwiftData

/// Determines how multiple selected categories are combined when filtering landmarks
enum CategoryFilterMode: String, Codable {
    /// Show landmarks that match ANY of the selected categories (OR logic)
    case matchAny
    /// Show landmarks that match ALL of the selected categories (AND logic)
    case matchAll
}

/// Manages the set of categories currently selected for filtering landmarks on the map.
/// This is a singleton model that persists which categories the user has selected.
/// 
/// The LandmarkCategory model used to have an `isSelected` property, but
/// it proved difficult to work with on complex queries, as did App Settings, so I'm
/// hoping this is the solution.
@Model
class SelectedCategories {
    
    /// The categories currently selected for filtering
    @Relationship(deleteRule: .nullify) var categories: [LandmarkCategory] = []
    
    /// The raw string value of the filter mode (for SwiftData persistence)
    private var filterModeRawValue: String = CategoryFilterMode.matchAny.rawValue
    
    /// The filter mode determining how multiple categories are combined
    var filterMode: CategoryFilterMode {
        get {
            CategoryFilterMode(rawValue: filterModeRawValue) ?? .matchAny
        }
        set {
            filterModeRawValue = newValue.rawValue
        }
    }
    
    /// Creates a new SelectedCategories instance
    init(categories: [LandmarkCategory] = [], filterMode: CategoryFilterMode = .matchAny) {
        self.categories = categories
        self.filterModeRawValue = filterMode.rawValue
    }
    
    /// Checks if a category is currently selected
    /// - Parameter category: The category to check
    /// - Returns: True if the category is in the selected set
    func contains(_ category: LandmarkCategory) -> Bool {
        categories.contains(category)
    }
    
    /// Toggles the selection state of a category
    /// - Parameter category: The category to toggle
    func toggle(_ category: LandmarkCategory) {
        if let index = categories.firstIndex(of: category) {
            categories.remove(at: index)
        } else {
            categories.append(category)
        }
    }
    
    /// Clears all selected categories
    func clearAll() {
        categories.removeAll()
    }
}
