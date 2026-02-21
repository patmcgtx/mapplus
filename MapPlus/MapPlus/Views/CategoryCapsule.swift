//
//  CategoryCapsule.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/20/26.
//
import SwiftUI
import SwiftData

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
    let includeDeleteButton: Bool
    
    var body: some View {
        HStack {
            Text(category.name.uppercased())
                .fontWeight(.black)
                .fontDesign(.rounded)
                .shadow(radius: 1.0)
            if includeDeleteButton {
                Button(action: {
                    try? storageService.remove(category: category,
                                               from: landmark)
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
                    includeDeleteButton: false
    )
    .modelContainer(try! ModelContainer.inMemorySampleContainer())
}

#Preview("Short with delete") {
    CategoryCapsule(category: LandmarkCategory(name: "Cafes"),
                    landmark: LandmarkSampleData().capital,
                    includeDeleteButton: true
    )
    .modelContainer(try! ModelContainer.inMemorySampleContainer())
}

#Preview("Medium long name") {
    CategoryCapsule(
        category: LandmarkCategory(
            name: "Pretty long category name"
        ),
        landmark: LandmarkSampleData().capital,
        includeDeleteButton: false
    )
    .modelContainer(try! ModelContainer.inMemorySampleContainer())
}

#Preview("Pretty long name") {
    CategoryCapsule(
        category: LandmarkCategory(
            name: "This is a really long category name and it is going to be really long and it will probably break the preview"
        ),
        landmark: LandmarkSampleData().capital,
        includeDeleteButton: false
    )
    .modelContainer(try! ModelContainer.inMemorySampleContainer())
}
