//
//  CategorySelectionService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 5/31/26.
//
import SwiftData

/// A service for keeping track of category selections.
/// This service uses SwiftData for persistence. Since SwiftData can be wired with any kind of
/// `ModelContext`, it can be used for previews and tests, so a protocol and mocks are not necessary.
@Observable
class CategorySelectionService {

    // MARK: - Dependencies
    
    private let modelContext: ModelContext
    
    // MARK: - State
    
    /// The selection model (lazy-loaded and cached)
    private var _selectedCategoriesModel: SelectedCategories?
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Public Properties
    
    /// The currently selected categories
    var selectedCategories: [LandmarkCategory] {
        selectedCategoriesModel?.categories ?? []
    }
    
    /// Whether there are any selected categories
    var hasSelectedCategories: Bool {
        !selectedCategories.isEmpty
    }
    
    /// The current filter mode
    var filterMode: CategoryFilterMode {
        get {
            selectedCategoriesModel?.filterMode ?? .matchAny
        }
        set {
            guard let model = selectedCategoriesModel else { return }
            model.filterMode = newValue
            save()
        }
    }
    
    /// Whether the filter mode picker should be shown (only relevant when 2+ categories selected)
    var shouldShowFilterModePicker: Bool {
        selectedCategories.count >= 2
    }
    
    // MARK: - Public Methods
    
    /// Filters landmarks based on the current category selection and filter mode
    /// - Parameter landmarks: The landmarks to filter
    /// - Returns: Filtered landmarks matching the selection criteria
    func filterLandmarks(_ landmarks: [Landmark]) -> [Landmark] {
        guard !selectedCategories.isEmpty else {
            return landmarks
        }
        
        let mode = filterMode
        let selected = selectedCategories
        
        return landmarks.filter { landmark in
            switch mode {
            case .matchAny:
                // Show landmarks that have at least one matching category (OR logic)
                landmark.categories.contains { category in
                    selected.contains(category)
                }
            case .matchAll:
                // Show landmarks that have all selected categories (AND logic)
                selected.allSatisfy { selectedCategory in
                    landmark.categories.contains(selectedCategory)
                }
            }
        }
    }
    
    /// Checks if a category is currently selected
    /// - Parameter category: The category to check
    /// - Returns: True if the category is selected
    func isSelected(_ category: LandmarkCategory) -> Bool {
        selectedCategoriesModel?.contains(category) ?? false
    }
    
    /// Toggles the selection state of a category
    /// - Parameter category: The category to toggle
    func toggle(_ category: LandmarkCategory) {
        guard let model = selectedCategoriesModel else {
            // Create a new model if one doesn't exist
            let newModel = SelectedCategories(categories: [category])
            modelContext.insert(newModel)
            _selectedCategoriesModel = newModel
            save()
            return
        }
        
        model.toggle(category)
        save()
    }
    
    /// Clears all category selections
    func clearAllSelections() {
        selectedCategoriesModel?.clearAll()
        save()
    }
    
    /// Sets the filter mode for combining multiple categories
    /// - Parameter mode: The filter mode to use
    func setFilterMode(_ mode: CategoryFilterMode) {
        filterMode = mode
    }
    
    // MARK: - Private Methods
    
    /// Gets or creates the SelectedCategories model
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
        
        // Create a new one if none exists
        let newModel = SelectedCategories()
        modelContext.insert(newModel)
        _selectedCategoriesModel = newModel
        save()
        return newModel
    }
    
    /// Saves the model context
    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save selected categories: \(error)")
        }
    }
}
