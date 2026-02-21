//
//  CategoryCapsule.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/20/26.
//
import SwiftUI

/// A "capsule" view of a category, such as to be shown in a flow layout of categories.
struct CategoryCapsule: View {

    // Persistence
    @Environment(\.modelContext) private var modelContext
    private var storageService: LandmarkStorageService {
        LandmarkStorageService(modelContext: modelContext)
    }

    // TODO patmcg doc
    let category: LandmarkCategory
    let landmark: Landmark
    let deleteCompletion: ((LandmarkCategory) -> Void)?

    var body: some View {
        HStack {
            Text(category.name.uppercased())
                .fontWeight(.black)
                .fontDesign(.rounded)
                .shadow(radius: 1.0)
            if let completion = deleteCompletion {
                Button(action: {
                    completion(category)
                }, label: {
                    Image(systemName: "x.circle")
                })
            }
        }
        .foregroundStyle(.primary)
        .colorInvert()
        .padding(
            EdgeInsets(
                top: 5,
                leading: 10,
                bottom: 5,
                trailing: 10
            )
        )
        .background {
            Capsule(style: .circular)
                .fill(.primary)
        }
    }
}

#Preview("Short") {
    CategoryCapsule(category: LandmarkCategory(name: "Cafes"),
                    landmark: LandmarkSampleData().capital,
                    deleteCompletion: nil
    )
}

#Preview("Short with delete") {
    CategoryCapsule(category: LandmarkCategory(name: "Cafes"),
                    landmark: LandmarkSampleData().capital,
                    deleteCompletion: { _ in }
    )
}

#Preview("Medium long name") {
    CategoryCapsule(
        category: LandmarkCategory(
            name: "Pretty long category name"
        ),
        landmark: LandmarkSampleData().capital,
        deleteCompletion: nil
    )
}

#Preview("Pretty long with delete") {
    CategoryCapsule(
        category: LandmarkCategory(
            name: "This is a really long category name and it is going to be really long and it will probably break the preview"
        ),
        landmark: LandmarkSampleData().capital,
        deleteCompletion: { _ in }
    )
}
