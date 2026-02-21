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
    
    let categories: [LandmarkCategory]
    let landmark: Landmark
    let deleteCompletion: ((LandmarkCategory) -> Void)?

    var body: some View {
        if categories.isEmpty {
            EmptyView()
        } else {
            HFlow {
                ForEach(categories) { category in
                    CategoryCapsule(category: category,
                                    landmark: landmark,
                                    deleteCompletion: deleteCompletion)
                }
            }
        }
    }
}

#Preview("Several") {
    CategoryFlow(
        categories: [
            LandmarkCategory(name: "one"),
            LandmarkCategory(name: "two"),
            LandmarkCategory(name: "three"),
            LandmarkCategory(name: "four"),
            LandmarkCategory(name: "five"),
            LandmarkCategory(name: "six"),
            LandmarkCategory(name: "seven"),
            LandmarkCategory(name: "eight"),
        ],
        landmark: LandmarkSampleData().capital,
        deleteCompletion: nil
    )
}

#Preview("One") {
    CategoryFlow(
        categories: [
            LandmarkCategory(name: "one"),
        ],
        landmark: LandmarkSampleData().capital,
        deleteCompletion: nil
    )
}

#Preview("Two - delete") {
    CategoryFlow(
        categories: [
            LandmarkCategory(name: "one"),
            LandmarkCategory(name: "two")
        ],
        landmark: LandmarkSampleData().capital,
        deleteCompletion: {category in
            print("Deleted: \(category.name)")
        }
    )
}

#Preview("Three") {
    CategoryFlow(
        categories: [
            LandmarkCategory(name: "one"),
            LandmarkCategory(name: "two"),
            LandmarkCategory(name: "three")
        ],
        landmark: LandmarkSampleData().capital,
        deleteCompletion: nil
    )
}

#Preview("None") {
    CategoryFlow(categories: [],
                 landmark: LandmarkSampleData().capital,
                 deleteCompletion: { category in
        print("Deleted: \(category.name)")
    })
}

