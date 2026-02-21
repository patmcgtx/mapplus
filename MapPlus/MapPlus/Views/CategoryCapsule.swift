//
//  CategoryCapsule.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/20/26.
//
import SwiftUI

/// A "capsule" view of a category, such as to be shown in a flow layout of categories.
struct CategoryCapsule: View {
    
    // TODO patmcg doc
    let category: LandmarkCategory

    // TODO patmcg doc
    @Binding var fromCategories: [LandmarkCategory]

    // Persistence
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack {
            Text(category.name.uppercased())
                .fontWeight(.black)
                .fontDesign(.rounded)
                .shadow(radius: 1.0)
            
            // TODO patmcg make button optional
            Button(action: {
                print("+++ Removing category: \(category.name)")
                withAnimation {
                    self.fromCategories.removeAll { $0.name == category.name }
                }
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
    @Previewable @State var categories: [LandmarkCategory] = [
        LandmarkCategory(name: "Cafes")
    ]
    CategoryCapsule(category: LandmarkCategory(name: "Cafes"),
                    fromCategories: $categories)
}

#Preview("Short with delete") {
    @Previewable @State var categories: [LandmarkCategory] = [
        LandmarkCategory(name: "Cafes"),
        LandmarkCategory(name: "Restaurants"),
        LandmarkCategory(name: "Hotels")
    ]
    CategoryCapsule(category: LandmarkCategory(name: "Cafes"),
                    fromCategories: $categories)
}

#Preview("Medium long name") {
    CategoryCapsule(
        category: LandmarkCategory(
            name: "Pretty long category name"
        ), fromCategories: .constant([])
    )
}

#Preview("Pretty long with delete") {
    CategoryCapsule(
        category: LandmarkCategory(
            name: "This is a really long category name and it is going to be really long and it will probably break the preview"
        ), fromCategories: .constant([])
    )
}
