//
//  CategoryFilterView.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/23/26.
//

import SwiftUI

// TODO patmcg remove this

/// A view for filtering which landmarks appear on the map by category.
struct CategoryFilterView: View {

    // Environment
    @Environment(\.dismiss) var dismiss

    /// All available categories to filter by
    let allCategories: [LandmarkCategory]

    /// The names of the currently-selected (active) filter categories
    @Binding var selectedCategoryNames: Set<String>

    var body: some View {
        NavigationStack {
            List {
                ForEach(allCategories, id: \.id) { category in
                    Button {
                        if selectedCategoryNames.contains(category.name) {
                            selectedCategoryNames.remove(category.name)
                        } else {
                            selectedCategoryNames.insert(category.name)
                        }
                    } label: {
                        HStack {
                            Text(category.name)
                            Spacer()
                            if selectedCategoryNames.contains(category.name) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }
            .navigationTitle("filter-places".localized)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("dismiss".localized, systemImage: "xmark") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("show-all".localized) {
                        selectedCategoryNames = []
                    }
                    .disabled(selectedCategoryNames.isEmpty)
                }
            }
        }
    }
}

#if DEBUG

// MARK: - Previews

#Preview("No selection") {
    @Previewable @State var selected: Set<String> = []
    CategoryFilterView(
        allCategories: SampleCategories().all,
        selectedCategoryNames: $selected
    )
}

#Preview("With selection") {
    @Previewable @State var selected: Set<String> = ["Cafes", "Fun"]
    CategoryFilterView(
        allCategories: SampleCategories().all,
        selectedCategoryNames: $selected
    )
}

#endif // DEBUG
