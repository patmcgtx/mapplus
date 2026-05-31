//
//  CategoriesSelectFlowViewModel.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 5/30/26.
//

import SwiftData

/// Manages the state and business logic for category selection
/// This is now a lightweight wrapper around CategorySelectionService
@Observable
class CategoriesSelectFlowViewModel {
    
    // MARK: - Dependencies
    
    private let service: CategorySelectionService
    
    // MARK: - State
    
    /// Whether there are any selected categories
    var hasSelectedCategories: Bool {
        service.hasSelectedCategories
    }
    
    /// The current filter mode
    var filterMode: CategoryFilterMode {
        service.filterMode
    }
    
    /// Whether the filter mode picker should be shown (only relevant when 2+ categories selected)
    var shouldShowFilterModePicker: Bool {
        service.shouldShowFilterModePicker
    }
    
    // MARK: - Initialization
    
    init(service: CategorySelectionService) {
        self.service = service
    }
    
    // MARK: - Public Methods
    
    /// Clears all category selections
    func clearAllSelections() {
        service.clearAllSelections()
    }
    
    /// Sets the filter mode for combining multiple categories
    /// - Parameter mode: The filter mode to use
    func setFilterMode(_ mode: CategoryFilterMode) {
        service.setFilterMode(mode)
    }
}
