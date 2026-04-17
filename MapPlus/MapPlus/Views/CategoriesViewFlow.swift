//
//  CategoryFlow.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/20/26.
//
import SwiftUI
import Flow

/// Displays a read-only collection of landmark categories in a horizontal flow layout
struct CategoriesViewFlow: View {
    
    /// The categories to update on edit / delete
    @Binding var categories: [LandmarkCategory]
    
    var body: some View {
        if categories.isEmpty {
            EmptyView()
        } else {
            HFlow {
                // TODO patmcg encapsulate this sorting here???
                ForEach(categories, id: \.id) { category in
                    CategoryCapsule(category: category,
                                    mode: .view,
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
    CategoriesViewFlow(categories: $categories)
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
    CategoriesViewFlow(categories: $categories)
}

#Preview("One") {
    @Previewable @State var categories: [LandmarkCategory] = [
        LandmarkCategory(name: "one")
    ]
    CategoriesViewFlow(categories: $categories)
}

#Preview("One - edit") {
    @Previewable @State var categories: [LandmarkCategory] = [
        LandmarkCategory(name: "one")
    ]
    CategoriesViewFlow(categories: $categories)
}

#Preview("Two") {
    @Previewable @State var categories: [LandmarkCategory] = [
        LandmarkCategory(name: "one"),
        LandmarkCategory(name: "two")
    ]
    CategoriesViewFlow(categories: $categories)
}

#Preview("Two - edit") {
    @Previewable @State var categories: [LandmarkCategory] = [
        LandmarkCategory(name: "one"),
        LandmarkCategory(name: "two")
    ]
    CategoriesViewFlow(categories: $categories)
}

#Preview("None") {
    @Previewable @State var categories: [LandmarkCategory] = []
    CategoriesViewFlow(categories: $categories)
}

#endif // DEBUG

