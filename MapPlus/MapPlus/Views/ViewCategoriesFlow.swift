//
//  ViewCategoriesFlow.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/20/26.
//
import SwiftUI
import Flow

/// Displays a read-only list of landmark categories in a horizontal flow layout
struct ViewCategoriesFlow: View {

    /// The categories to display
    let categories: [LandmarkCategory]

    var body: some View {
        if categories.isEmpty {
            EmptyView()
        } else {
            HFlow {
                ForEach(categories, id: \.id) { category in
                    CategoryCapsule(category: category,
                                    mode: .view,
                                    fromCategories: .constant(categories))
                }
            }
        }
    }
}

#if DEBUG

#Preview("Several") {
    ViewCategoriesFlow(categories: [
        LandmarkCategory(name: "one"),
        LandmarkCategory(name: "two"),
        LandmarkCategory(name: "three"),
        LandmarkCategory(name: "four"),
        LandmarkCategory(name: "five"),
        LandmarkCategory(name: "six"),
        LandmarkCategory(name: "seven"),
        LandmarkCategory(name: "eight"),
    ])
}

#Preview("One") {
    ViewCategoriesFlow(categories: [
        LandmarkCategory(name: "one")
    ])
}

#Preview("Two") {
    ViewCategoriesFlow(categories: [
        LandmarkCategory(name: "one"),
        LandmarkCategory(name: "two")
    ])
}

#Preview("None") {
    ViewCategoriesFlow(categories: [])
}

#endif // DEBUG
