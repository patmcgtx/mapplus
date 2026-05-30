//
//  CategorySelectionManager.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 5/30/26.
//

import SwiftUI
import SwiftData
import Foundation

/// Manages the selection state of landmark categories using AppStorage.
/// This separates UI state from the data model, allowing category selection
/// to persist across app launches without modifying the model itself.
/// Uses stable UUIDs to track selections, so renaming categories won't break selection state.
@Observable
class CategorySelection {
    
    /// Set of selected category IDs, stored in UserDefaults
    @ObservationIgnored
    @AppStorage("selectedCategoryIDs") private var selectedCategoryIDsData: Data = Data()
    
    /// Cached set of selected category IDs for performance
    private var selectedCategoryIDs: Set<UUID> = []
    
    init() {
        loadSelectedCategories()
    }
    
    /// Checks if a category is selected
    /// - Parameter category: The category to check
    /// - Returns: True if the category is selected
    func isSelected(_ category: LandmarkCategory) -> Bool {
        selectedCategoryIDs.contains(category.id)
    }
    
    /// Toggles the selection state of a category
    /// - Parameter category: The category to toggle
    func toggle(_ category: LandmarkCategory) {
        if selectedCategoryIDs.contains(category.id) {
            selectedCategoryIDs.remove(category.id)
        } else {
            selectedCategoryIDs.insert(category.id)
        }
        saveSelectedCategories()
    }
    
    /// Clears all category selections
    func clearAll() {
        selectedCategoryIDs.removeAll()
        saveSelectedCategories()
    }
    
    /// Returns all selected category IDs
    var selectedIDs: Set<UUID> {
        selectedCategoryIDs
    }
    
    /// Returns whether any categories are selected
    var hasSelections: Bool {
        !selectedCategoryIDs.isEmpty
    }
    
    // MARK: - Private Helpers
    
    private func loadSelectedCategories() {
        guard !selectedCategoryIDsData.isEmpty else {
            selectedCategoryIDs = []
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode(Set<UUID>.self, from: selectedCategoryIDsData)
            selectedCategoryIDs = decoded
        } catch {
            print("Failed to decode selected categories: \(error)")
            selectedCategoryIDs = []
        }
    }
    
    private func saveSelectedCategories() {
        do {
            let encoded = try JSONEncoder().encode(selectedCategoryIDs)
            selectedCategoryIDsData = encoded
        } catch {
            print("Failed to encode selected categories: \(error)")
        }
    }
}
