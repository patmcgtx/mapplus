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
                    CategoryCapsule(category: category)
                }
            }
        }
    }
}

#Preview("Several") {
    CategoryFlow(
        categories: .constant([
            LandmarkCategory(name: "one"),
            LandmarkCategory(name: "two"),
            LandmarkCategory(name: "three"),
            LandmarkCategory(name: "four"),
            LandmarkCategory(name: "five"),
            LandmarkCategory(name: "six"),
            LandmarkCategory(name: "seven"),
            LandmarkCategory(name: "eight"),
        ])
    )
}

#Preview("One") {
    CategoryFlow(
        categories: .constant([
            LandmarkCategory(name: "one"),
        ])
    )
}

#Preview("Two - delete") {
    CategoryFlow(
        categories: .constant([
            LandmarkCategory(name: "one"),
            LandmarkCategory(name: "two")
        ])
    )
}

#Preview("Three") {
    CategoryFlow(
        categories: .constant([
            LandmarkCategory(name: "one"),
            LandmarkCategory(name: "two"),
            LandmarkCategory(name: "three")
        ])
    )
}

#Preview("None") {
    CategoryFlow(categories: .constant([]))
}

