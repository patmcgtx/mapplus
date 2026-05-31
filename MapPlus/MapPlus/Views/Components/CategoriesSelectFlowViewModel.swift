//
//  CategoriesSelectFlowViewModel.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 5/30/26.
//

import SwiftData

/// Manages the state and business logic for category selection
@Observable
class CategoriesSelectFlowViewModel {
    
    // MARK: - Dependencies
    
    private let modelContext: ModelContext
    
    // MARK: - State
    
    /// The selection model (lazy-loaded)
    private var _selectedCategoriesModel: SelectedCategories?
    
    /// Whether there are any selected categories
    var hasSelectedCategories: Bool {
        selectedCategoriesModel?.categories.isEmpty == false
    }
    
    /// The current filter mode
    var filterMode: CategoryFilterMode {
        selectedCategoriesModel?.filterMode ?? .matchAny
    }
    
    /// Whether the filter mode picker should be shown (only relevant when 2+ categories selected)
    var shouldShowFilterModePicker: Bool {
        (selectedCategoriesModel?.categories.count ?? 0) >= 2
    }
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Public Methods
    
    /// Clears all category selections
    func clearAllSelections() {
        guard let selectedCategoriesModel else { return }
        selectedCategoriesModel.clearAll()
        save()
    }
    
    /// Sets the filter mode for combining multiple categories
    /// - Parameter mode: The filter mode to use
    func setFilterMode(_ mode: CategoryFilterMode) {
        guard let selectedCategoriesModel else { return }
        selectedCategoriesModel.filterMode = mode
        save()
    }
    
    // MARK: - Private Methods
    
    /// Gets the SelectedCategories model if one exists
    private var selectedCategoriesModel: SelectedCategories? {
        // Return cached if available
        if let existing = _selectedCategoriesModel {
            return existing
        }
        
        // Try to fetch from context
        let descriptor = FetchDescriptor<SelectedCategories>()
        if let fetched = try? modelContext.fetch(descriptor).first {
            _selectedCategoriesModel = fetched
            return fetched
        }
        
        return nil
    }
    
    /// Saves the model context
    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save category selection: \(error)")
        }
    }
}
