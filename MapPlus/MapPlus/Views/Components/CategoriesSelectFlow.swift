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
                ForEach($allCategories) { category in
                    CategoryCapsule(
                        category: category,
                        canToggle: true,
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
    CategoriesSelectFlow(allCategories: $categories)
    let selected = categories.filter(\.isSelected)
    Text(selected.map(\.name).joined(separator: ", "))
}

#endif // DEBUG
