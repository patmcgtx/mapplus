//
//  EditCategoriesFlow.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/20/26.
//
import SwiftUI
import Flow

/// Displays a list of landmark categories in a horizontal flow layout, with delete buttons for editing
struct EditCategoriesFlow: View {

    /// The categories to update on delete
    @Binding var categories: [LandmarkCategory]

    var body: some View {
        if categories.isEmpty {
            EmptyView()
        } else {
            HFlow {
                ForEach(categories, id: \.id) { category in
                    CategoryCapsule(category: category,
                                    mode: .edit,
                                    fromCategories: $categories)
                }
            }
        }
    }
}

#if DEBUG

#Preview("Several") {
    @Previewable @State var categories: [LandmarkCategory] = [
        LandmarkCategory(name: "one"),
        LandmarkCategory(name: "two"),
        LandmarkCategory(name: "three"),
        LandmarkCategory(name: "four"),
        LandmarkCategory(name: "five"),
        LandmarkCategory(name: "six"),
        LandmarkCategory(name: "seven"),
        LandmarkCategory(name: "eight"),
    ]
    EditCategoriesFlow(categories: $categories)
}

#Preview("One") {
    @Previewable @State var categories: [LandmarkCategory] = [
        LandmarkCategory(name: "one")
    ]
    EditCategoriesFlow(categories: $categories)
}

#Preview("Two") {
    @Previewable @State var categories: [LandmarkCategory] = [
        LandmarkCategory(name: "one"),
        LandmarkCategory(name: "two")
    ]
    EditCategoriesFlow(categories: $categories)
}

#Preview("None") {
    @Previewable @State var categories: [LandmarkCategory] = []
    EditCategoriesFlow(categories: $categories)
}

#endif // DEBUG
