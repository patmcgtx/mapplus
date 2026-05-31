//
//  CategoriesSelectFlowViewModel.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 5/30/26.
//

import SwiftUI
import SwiftData

/// Manages the state and business logic for category selection
@Observable
class CategoriesSelectFlowViewModel {
    
    // MARK: - Dependencies
    
    private let modelContext: ModelContext
    
    // MARK: - State
    
    /// All available categories
    private(set) var allCategories: [LandmarkCategory] = []
    
    /// The selection model (lazy-loaded)
    private var _selectedCategoriesModel: SelectedCategories?
    
    /// Whether there are any selected categories
    var hasSelectedCategories: Bool {
        selectedCategoriesModel?.categories.isEmpty == false
    }
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Public Methods
    
    /// Loads categories from the model context
    func loadCategories() {
        let descriptor = FetchDescriptor<LandmarkCategory>(
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            allCategories = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch categories: \(error)")
            allCategories = []
        }
    }
    
    /// Clears all category selections
    func clearAllSelections() {
        guard let selectedCategoriesModel else { return }
        selectedCategoriesModel.clearAll()
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
