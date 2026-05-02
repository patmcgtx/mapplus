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
        
    // We're going to show all categories for filtering
    @Query(sort: \LandmarkCategory.name) private var allCategories: [LandmarkCategory]
    
    @State private var isShowingEditView = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button(
                    action: { dismiss() },
                    label: { Image(systemName: "xmark.circle") }
                )

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
        allCategories.contains { $0.isSelected }
    }

    private func clearAllSelections() {
        for index in allCategories.indices {
            allCategories[index].isSelected = false
        }
    }
}

#if DEBUG

private struct SelectedCategoriesView: View {
    
    @Query(filter: #Predicate<LandmarkCategory> { $0.isSelected })
    private var selectedCategories: [LandmarkCategory]
    
    var body: some View {
        Text("selected-categories".localized).bold()
        let selected = selectedCategories.map{ $0.name }.joined(separator: ", ")
        Text(selected)
    }
}

#Preview("Basic") {
    VStack {
        CategoriesSelectFlow()
        SelectedCategoriesView()
    }
    .modelContainer(
        try! ModelContainer.inMemorySampleContainer()
    )
}

#Preview("Many") {
    VStack {
        CategoriesSelectFlow()
        SelectedCategoriesView()
    }
    .modelContainer(
        try! ModelContainer.inMemorySampleContainer(
            numExtraCategories: 50
        )
    )
}

#endif // DEBUG

