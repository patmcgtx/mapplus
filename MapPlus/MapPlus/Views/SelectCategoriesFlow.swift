//
//  SelectCategoriesFlow.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/20/26.
//
import SwiftUI
import Flow

/// Displays a list of landmark categories in a horizontal flow layout, allowing zero or more to be selected
struct SelectCategoriesFlow: View {

    /// The categories to display and select from
    @Binding var categories: [LandmarkCategory]

    var body: some View {
        if categories.isEmpty {
            EmptyView()
        } else {
            HFlow {
                ForEach(categories, id: \.id) { category in
                    CategoryCapsule(category: category,
                                    mode: .select,
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
    SelectCategoriesFlow(categories: $categories)
}

#Preview("One") {
    @Previewable @State var categories: [LandmarkCategory] = [
        LandmarkCategory(name: "one")
    ]
    SelectCategoriesFlow(categories: $categories)
}

#Preview("Two") {
    @Previewable @State var categories: [LandmarkCategory] = [
        LandmarkCategory(name: "one"),
        LandmarkCategory(name: "two")
    ]
    SelectCategoriesFlow(categories: $categories)
}

#Preview("None") {
    @Previewable @State var categories: [LandmarkCategory] = []
    SelectCategoriesFlow(categories: $categories)
}

#endif // DEBUG
