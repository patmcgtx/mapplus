//
//  CategoryFlow.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/20/26.
//
import SwiftUI
import Flow

/// Displays a read-only collection of landmark categories in a flow layout.
struct CategoriesViewFlow: View {
    
    /// The categories to display in the given order.
    @Binding var categories: [LandmarkCategory]
    
    var body: some View {
        if categories.isEmpty {
            EmptyView()
        } else {
            HFlow {
                ForEach(categories, id: \.id) { category in
                    CategoryCapsuleNew(
                        category: category,
                        canToggle: false,
                        action: nil
                    )
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

#Preview("Two") {
    @Previewable @State var categories: [LandmarkCategory] = [
        LandmarkCategory(name: "one"),
        LandmarkCategory(name: "two")
    ]
    CategoriesViewFlow(categories: $categories)
}

#Preview("One") {
    @Previewable @State var categories: [LandmarkCategory] = [
        LandmarkCategory(name: "one")
    ]
    CategoriesViewFlow(categories: $categories)
}

#Preview("None") {
    @Previewable @State var categories: [LandmarkCategory] = []
    CategoriesViewFlow(categories: $categories)
}

#endif // DEBUG

