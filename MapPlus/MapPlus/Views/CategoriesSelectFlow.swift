//
//  CategoriesSelectFlow.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 4/16/26.
//

import SwiftUI
import Flow

/// Displays landmark categories, allowing individual ones to be selected or unselected.
struct CategoriesSelectFlow: View {
        
    /// All available categories to filter by
    @Binding var allCategories: [LandmarkCategory]

//    /// The names of the currently-selected (active) filter categories
//    @Binding var selectedCategoryNames: Set<String>

    var body: some View {
        HFlow {
            ForEach($allCategories) { category in
                CategoryCapsuleNew(
                    category: category,
                    onToggle: { category in
//                        if selectedCategoryNames.contains(category.name) {
//                            selectedCategoryNames.remove(category.name)
//                        } else {
//                            selectedCategoryNames.insert(category.name)
//                        }
                    },
                    action: nil
                )
            }
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
    CategoriesSelectFlow(
        allCategories: $categories
//        selectedCategoryNames: $selectedCategoryNames
    )
    Text(selectedCategoryNames.joined(separator: ", "))
}

#endif // DEBUG
