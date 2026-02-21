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

    var body: some View {
        HStack {
            Text(category.name.uppercased())
                .fontWeight(.black)
                .fontDesign(.rounded)
                .shadow(radius: 1.0)
            
            // TODO patmcg needed?
            Button(action: {
                // TODO patmcg needed?
            }, label: {
                Image(systemName: "x.circle")
            })
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
    CategoryCapsule(category: LandmarkCategory(name: "Cafes"))
}

#Preview("Short with delete") {
    CategoryCapsule(category: LandmarkCategory(name: "Cafes"))
}

#Preview("Medium long name") {
    CategoryCapsule(
        category: LandmarkCategory(
            name: "Pretty long category name"
        )
    )
}

#Preview("Pretty long with delete") {
    CategoryCapsule(
        category: LandmarkCategory(
            name: "This is a really long category name and it is going to be really long and it will probably break the preview"
        )
    )
}
