//
//  CategoriesEditViewModel.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 4/25/26.
//

import SwiftUI
import SwiftData

/// View model for managing category editing operations
@MainActor
@Observable
final class CategoriesEditViewModel {
    
    // MARK: UI State for observable / binding

    /// The name for a new category being added
    var newCategoryName: String = ""
    
    /// The category currently being edited, if any
    var editingCategory: LandmarkCategory?
    
    /// The edited name for the category being renamed
    var editedName: String = ""
    
    /// The category for which a delete alert should be shown, if any
    var showingDeleteAlert: LandmarkCategory?

    /// The model context for SwiftData operations
    private let modelContext: ModelContext
    
    // MARK: Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: Actions
    
    /// Adds a new category with the current name
    /// - Parameter allCategories: All existing categories to check for duplicates
    /// - Returns: True if the category was added successfully, false otherwise
    @discardableResult
    func addCategory(allCategories: [LandmarkCategory]) -> Bool {
        let trimmedName = newCategoryName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return false }
        
        // Check if category already exists
        if allCategories.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) {
            // Could show an error here
            return false
        }
        
        let newCategory = LandmarkCategory(name: trimmedName)
        modelContext.insert(newCategory)
        
        do {
            try modelContext.save()
            newCategoryName = ""
            return true
        } catch {
            print("Failed to add category: \(error)")
            return false
        }
    }
    
    /// Starts editing a category
    /// - Parameter category: The category to edit
    func startEditing(_ category: LandmarkCategory) {
        editingCategory = category
        editedName = category.name
    }
    
    /// Saves the edit for a category
    /// - Parameters:
    ///   - category: The category being edited
    ///   - allCategories: All existing categories to check for duplicate names
    /// - Returns: True if the edit was saved successfully, false otherwise
    @discardableResult
    func saveEdit(for category: LandmarkCategory, allCategories: [LandmarkCategory]) -> Bool {
        let trimmedName = editedName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return false }
        
        // Check if another category already has this name
        if allCategories.contains(where: {
            $0.id != category.id && $0.name.lowercased() == trimmedName.lowercased()
        }) {
            // Could show an error here
            return false
        }
        
        category.name = trimmedName
        
        do {
            try modelContext.save()
            cancelEdit()
            return true
        } catch {
            print("Failed to save category edit: \(error)")
            return false
        }
    }
    
    /// Cancels the current edit operation
    func cancelEdit() {
        editingCategory = nil
        editedName = ""
    }
    
    /// Deletes a category
    /// - Parameter category: The category to delete
    /// - Returns: True if the category was deleted successfully, false otherwise
    @discardableResult
    func deleteCategory(_ category: LandmarkCategory) -> Bool {
        modelContext.delete(category)
        
        do {
            try modelContext.save()
            return true
        } catch {
            print("Failed to delete category: \(error)")
            return false
        }
    }
}
