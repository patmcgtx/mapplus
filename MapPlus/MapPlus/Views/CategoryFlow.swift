//
//  CategoryFlow.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/20/26.
//
import SwiftUI
import Flow

/// Displays a list of landmark categories in a horizontal flow layout
struct CategoryFlow: View {
    
    /// The categories to update on edit / delete
    @Binding var categories: [LandmarkCategory]
    
    /// Read-only or edit?
    let mode: CategoryCapsule.Mode

    var body: some View {
        if categories.isEmpty {
            EmptyView()
        } else {
            HFlow {
                // TODO patmcg encapsulate this sorting here???
                ForEach(categories, id: \.id) { category in
                    CategoryCapsule(category: category,
                                    mode: mode,
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
    CategoryFlow(categories: $categories, mode: .view)
}

#Preview("Several - edit") {
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
    CategoryFlow(categories: $categories, mode: .edit)
}

#Preview("One") {
    @Previewable @State var categories: [LandmarkCategory] = [
        LandmarkCategory(name: "one")
    ]
    CategoryFlow(categories: $categories, mode: .view)
}

#Preview("One - edit") {
    @Previewable @State var categories: [LandmarkCategory] = [
        LandmarkCategory(name: "one")
    ]
    CategoryFlow(categories: $categories, mode: .edit)
}

#Preview("Two") {
    @Previewable @State var categories: [LandmarkCategory] = [
        LandmarkCategory(name: "one"),
        LandmarkCategory(name: "two")
    ]
    CategoryFlow(categories: $categories, mode: .view)
}

#Preview("Two - edit") {
    @Previewable @State var categories: [LandmarkCategory] = [
        LandmarkCategory(name: "one"),
        LandmarkCategory(name: "two")
    ]
    CategoryFlow(categories: $categories, mode: .edit)
}

#Preview("None") {
    @Previewable @State var categories: [LandmarkCategory] = []
    CategoryFlow(categories: $categories, mode: .view)
}

#endif // DEBUG

