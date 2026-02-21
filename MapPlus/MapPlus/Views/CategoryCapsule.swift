//
//  CategoryCapsule.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/20/26.
//
import SwiftUI

/// A "capsule" view of a category, such as to be shown in a flow layout of categories.
struct CategoryCapsule: View {
    
    /// Options for viewing or editing the category
    enum Mode {
        /// View the capsule read-only
        case view
        /// View the capsule in edit mode (with a delete button)
        case edit
    }
    
    /// Which category to represent
    let category: LandmarkCategory
    
    /// Read-only or edit?
    let mode: Mode

    /// The categories to update on edit / delete
    @Binding var fromCategories: [LandmarkCategory]

    var body: some View {
        HStack {
            Text(category.name.uppercased())
                .fontWeight(.black)
                .fontDesign(.rounded)
                .shadow(radius: 1.0)
            
            if .edit == mode {
                Button(action: {
                    withAnimation {
                        self.fromCategories.removeAll { $0.name == category.name }
                    }
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
    @Previewable @State var categories: [LandmarkCategory] = [
        LandmarkCategory(name: "Cafes")
    ]
    CategoryCapsule(category: LandmarkCategory(name: "Cafes"),
                    mode: .view,
                    fromCategories: $categories)
}

#Preview("Short with delete") {
    @Previewable @State var categories: [LandmarkCategory] = [
        LandmarkCategory(name: "Cafes"),
        LandmarkCategory(name: "Restaurants"),
        LandmarkCategory(name: "Hotels")
    ]
    CategoryCapsule(category: LandmarkCategory(name: "Cafes"),
                    mode: .edit,
                    fromCategories: $categories)
}

#Preview("Medium long name") {
    CategoryCapsule(
        category: LandmarkCategory(
            name: "Pretty long category name"
        ),
        mode: .view,
        fromCategories: .constant([])
    )
}

#Preview("Medium long name - delete") {
    CategoryCapsule(
        category: LandmarkCategory(
            name: "Pretty long category name"
        ),
        mode: .edit,
        fromCategories: .constant([])
    )
}

#Preview("Pretty long with delete") {
    CategoryCapsule(
        category: LandmarkCategory(
            name: "This is a really long category name and it is going to be really long and it will probably break the preview"
        ),
        mode: .view,
        fromCategories: .constant([])
    )
}
