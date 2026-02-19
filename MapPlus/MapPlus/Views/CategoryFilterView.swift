//
//  CategoryFilterView.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/19/26.
//

import SwiftUI

/// A sheet that lets the user select which categories to show on the map.
/// An empty selection means "show all landmarks".
struct CategoryFilterView: View {

    let allCategories: [LandmarkCategory]

    @Binding var selectedCategories: Set<LandmarkCategory>

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(allCategories) { category in
                    Button {
                        toggleCategory(category)
                    } label: {
                        HStack {
                            CategoryCapsuleView(category: category)
                            Spacer()
                            if selectedCategories.contains(category) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                    .tint(.primary)
                }
            }
            .navigationTitle("filter-by-category".localized)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("done".localized) { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    if !selectedCategories.isEmpty {
                        Button("clear-filter".localized) {
                            selectedCategories.removeAll()
                        }
                    }
                }
            }
        }
    }

    private func toggleCategory(_ category: LandmarkCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
}

// MARK: - Previews

#Preview {
    @Previewable @State var selected: Set<LandmarkCategory> = []
    CategoryFilterView(
        allCategories: CategorySampleData().all,
        selectedCategories: $selected
    )
}
