//
//  MockCategorySelectionService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 5/31/26.
//

import SwiftData

#if DEBUG

/// A mock implementation for testing and previews.
@Observable
class MockCategorySelectionService: CategorySelectionService {
    
    // Mock State
    
    var selectedCategories: [LandmarkCategory] = []
    var filterMode: CategoryFilterMode = .matchAny
    
    // Computed Properties
    
    var hasSelectedCategories: Bool {
        !selectedCategories.isEmpty
    }
    
    var shouldShowFilterModePicker: Bool {
        selectedCategories.count >= 2
    }
    
    // Tracking for Tests
    
    var toggleCalls: [LandmarkCategory] = []
    var clearAllSelectionsCalls: Int = 0
    var setFilterModeCalls: [CategoryFilterMode] = []
    var filterLandmarksCalls: Int = 0
    
    // Methods
    
    func filterLandmarks(_ landmarks: [Landmark]) -> [Landmark] {
        filterLandmarksCalls += 1
        
        guard !selectedCategories.isEmpty else {
            return landmarks
        }
        
        return landmarks.filter { landmark in
            switch filterMode {
            case .matchAny:
                landmark.categories.contains { category in
                    selectedCategories.contains(category)
                }
            case .matchAll:
                selectedCategories.allSatisfy { selectedCategory in
                    landmark.categories.contains(selectedCategory)
                }
            }
        }
    }
    
    func isSelected(_ category: LandmarkCategory) -> Bool {
        selectedCategories.contains(category)
    }
    
    func toggle(_ category: LandmarkCategory) {
        toggleCalls.append(category)
        
        if let index = selectedCategories.firstIndex(of: category) {
            selectedCategories.remove(at: index)
        } else {
            selectedCategories.append(category)
        }
    }
    
    func clearAllSelections() {
        clearAllSelectionsCalls += 1
        selectedCategories.removeAll()
    }
    
    func setFilterMode(_ mode: CategoryFilterMode) {
        setFilterModeCalls.append(mode)
        filterMode = mode
    }
    
    // MARK: - Test Helpers
    
    func reset() {
        selectedCategories.removeAll()
        filterMode = .matchAny
        toggleCalls.removeAll()
        clearAllSelectionsCalls = 0
        setFilterModeCalls.removeAll()
        filterLandmarksCalls = 0
    }
}

#endif // DEBUG
