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
struct CategoriesSelectFlow: View {
        
    /// All available categories to filter by
//    @Binding var allCategories: [LandmarkCategory]
//    @Environment(\.modelContext) private var modelContext
    @Query private var allCategories: [LandmarkCategory]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("categories".localized)
                    .font(.headline)
                Spacer()
                if hasSelectedCategories {
                    Button("clear".localized) {
                        clearAllSelections()
                    }
                    .buttonStyle(.borderless)
                }
            }
            
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

#Preview {
    @Previewable @State var selectedCategoryNames: Set<String> = []
    @Previewable @State var categories: [LandmarkCategory] = [
        .init(name: "One"),
        .init(name: "Two"),
        .init(name: "Three")
    ]
    CategoriesSelectFlow()
        .modelContainer(try! ModelContainer.inMemorySampleContainer())
}

#endif // DEBUG
