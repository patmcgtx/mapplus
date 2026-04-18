//
//  CategoryCapsule.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/20/26.
//
import SwiftUI

/// A "capsule" view of a category, such as to be shown in a flow layout of categories.
struct CategoryCapsuleOld: View {
    
    /// Options for viewing or editing the category
    enum Mode {
        
        /// View the category read-only
        case view
        
        /// View the capsule in edit mode (with a delete button)
        case edit
        
        /// Select or unselect a category
        case select
    }
    
    /// Which category to represent
    let category: LandmarkCategory
    
    /// Read-only or edit?
    let mode: Mode

    /// The categories to update on edit / delete
    @Binding var fromCategories: [LandmarkCategory]

    var body: some View {
        HStack {
            let fontWeight: Font.Weight = category.isSelected ? .black : .bold
            Text(category.name.uppercased())
                .fontWeight(fontWeight)
                .fontDesign(.rounded)
                .shadow(radius: 1.0)
            
            switch mode {

            case .edit:
                Button(action: {
                    // I tried to handle the delete here, but it caused
                    // bugs, deleting *all* the categories.
                    // Handle it with .onTapGesture below instead.
                }, label: {
                    Image(systemName: "x.circle")
                })
                .onTapGesture {
                    withAnimation(.bouncy) {
                        // Delete the category from its parents
                        // TODO patmcg some way to abstract this?  Like a method on Landmark?
                        self.fromCategories.removeAll { $0.name == category.name }
                    }
                }
                
            case .select:
                Button(action: {
                }, label: {
                    Image(systemName: "plus")
                })
                .onTapGesture {
                    withAnimation(.bouncy) {
                        // TODO patmcg "select" or "unselect" here
                    }
                }

            default: EmptyView()
            }
        }
        .foregroundStyle(.primary)
        .padding(
            EdgeInsets(
                top: 4,
                leading: 15,
                bottom: 4,
                trailing: 15
            )
        )
        .background {
            Capsule(style: .circular)
                .strokeBorder(lineWidth: 2)
        }
    }
}

#if DEBUG

#Preview("Short") {
    CategoryCapsuleOld(category: LandmarkCategory(name: "Cafes"),
                    mode: .view,
                    fromCategories: .constant([]))
}

#Preview("Short - edit") {
    CategoryCapsuleOld(category: LandmarkCategory(name: "Cafes"),
                    mode: .edit,
                    fromCategories: .constant([]))
}

#Preview("Short - select") {
    CategoryCapsuleOld(category: LandmarkCategory(name: "Arcades"),
                    mode: .select,
                    fromCategories: .constant([]))
}

#Preview("Long name") {
    CategoryCapsuleOld(
        category: LandmarkCategory(
            name: "Pretty long category name"
        ),
        mode: .view,
        fromCategories: .constant([])
    )
}

#Preview("Long name - delete") {
    CategoryCapsuleOld(
        category: LandmarkCategory(
            name: "Pretty long category name"
        ),
        mode: .edit,
        fromCategories: .constant([])
    )
}

#Preview("Crazy long name with edit") {
    CategoryCapsuleOld(
        category: LandmarkCategory(
            name: "This is a really long category name and it is going to be really long and it will probably break the preview"
        ),
        mode: .edit,
        fromCategories: .constant([])
    )
}

#endif // DEBUG
