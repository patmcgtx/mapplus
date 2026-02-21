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
    
    @Binding var categories: [LandmarkCategory]

    var body: some View {
        if categories.isEmpty {
            EmptyView()
        } else {
            HFlow {
                ForEach(categories) { category in
                    CategoryCapsule(category: category,
                                    fromCategories: $categories)
                }
            }
        }
    }
}

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
    CategoryFlow(categories: $categories)
}

#Preview("One") {
    @Previewable @State var categories: [LandmarkCategory] = [
        LandmarkCategory(name: "one")
    ]
    CategoryFlow(categories: $categories)
}

#Preview("Two - delete") {
    @Previewable @State var categories: [LandmarkCategory] = [
        LandmarkCategory(name: "one"),
        LandmarkCategory(name: "two")
    ]
    CategoryFlow(categories: $categories)
}

#Preview("Three") {
    @Previewable @State var categories: [LandmarkCategory] = [
        LandmarkCategory(name: "one"),
        LandmarkCategory(name: "two"),
        LandmarkCategory(name: "three")
    ]
    CategoryFlow(categories: $categories)
}

#Preview("None") {
    @Previewable @State var categories: [LandmarkCategory] = []
    CategoryFlow(categories: $categories)
}

