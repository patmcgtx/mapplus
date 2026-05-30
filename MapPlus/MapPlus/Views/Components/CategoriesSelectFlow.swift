//
//  CategoriesSelectFlow.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 4/16/26.
//

import SwiftUI
import SwiftData
import Flow

/// Displays landmark categories, allowing individual ones to be selected or unselected.
/// Once presented, any of the known categories could become selected or deselected.
struct CategoriesSelectFlow: View {
    
    @Environment(\.dismiss) private var dismiss
    
    /// Manages category selection state
    var categorySelection: CategorySelection
        
    // We're going to show all categories for filtering
    @Query(sort: \LandmarkCategory.name) private var allCategories: [LandmarkCategory]
    
    @State private var isShowingEditView = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button(
                    action: {
                        dismiss()
                    },
                    label: {
                      Image(systemName: "xmark.circle")
                  })

                Spacer()
                
                HStack(spacing: 8) {
                    Button("clear".localized) {
                        clearAllSelections()
                    }
                    .buttonStyle(.bordered)
                    .disabled(!hasSelectedCategories)
                    
                    Divider()
                        .frame(height: 20)
                    
                    Button("edit".localized) {
                        isShowingEditView = true
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            ScrollView {
                HFlow {
                    ForEach(allCategories) { category in
                        CategoryCapsule(
                            category: category,
                            isSelectable: true,
                            categorySelection: categorySelection,
                            action: nil
                        )
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingEditView) {
            CategoriesEditView()
        }
    }
    
    private var hasSelectedCategories: Bool {
        categorySelection.hasSelections
    }

    private func clearAllSelections() {
        categorySelection.clearAll()
    }
}

#if DEBUG

private struct SelectedCategoriesView: View {
    
    var categorySelection: CategorySelection
    @Query(sort: \LandmarkCategory.name) private var allCategories: [LandmarkCategory]
    
    var body: some View {
        Text("selected-categories".localized).bold()
        let selectedIDs = categorySelection.selectedIDs
        let selectedNames = allCategories
            .filter { selectedIDs.contains($0.id) }
            .map { $0.name }
            .sorted()
            .joined(separator: ", ")
        Text(selectedNames.isEmpty ? "None" : selectedNames)
    }
}

#Preview("Basic") {
    @Previewable @State var categorySelection = CategorySelection()
    
    VStack {
        CategoriesSelectFlow(categorySelection: categorySelection)
        SelectedCategoriesView(categorySelection: categorySelection)
    }
    .modelContainer(
        try! ModelContainer.inMemorySampleContainer()
    )
}

#Preview("Many") {
    @Previewable @State var categorySelection = CategorySelection()
    
    VStack {
        CategoriesSelectFlow(categorySelection: categorySelection)
        SelectedCategoriesView(categorySelection: categorySelection)
    }
    .modelContainer(
        try! ModelContainer.inMemorySampleContainer(
            numExtraCategories: 50
        )
    )
}

#endif // DEBUG

