//
//  CategoryCapsuleNew.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 4/16/26.
//
import SwiftUI

/// A "capsule" view of a category, such as to be shown in a flow layout of categories.
struct CategoryCapsuleNew: View {

    /// Describes an action for the category
    struct Action {
        
        /// System image for an action on the category buttons
        let systemImage: String
        
        /// An action to take when the category button is tapped
        let onTap: (LandmarkCategory) -> Void
    }

    /// Which category to represent - TODO patmcg does this need a BInding?!
    let category: LandmarkCategory
    
    /// Does this category capsule allow toggling?
    let canToggle: Bool
    
    /// An optional action to add to the category
    let action: Action?
    
    // MARK: State
    
    @State private var isSelected: Bool = false
    
    // MARK: View

    var body: some View {
        HStack {
            let fontWeight: Font.Weight = isSelected ? .black : .bold
            Text(category.name.uppercased())
                .fontWeight(fontWeight)
                .fontDesign(.rounded)
                .shadow(radius: 1.0)
            
            if let categoryAction = action {
                Button(action: {
                    categoryAction.onTap(category)
                }, label: {
                    Image(systemName: categoryAction.systemImage)
                })
            }
        }
        .onTapGesture {
            if canToggle {
                withAnimation() {
                    isSelected.toggle()
                    category.isSelected = isSelected
                }
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
                .strokeBorder(lineWidth: isSelected ? 2.0 : 1.0)
        }
    }
}

#if DEBUG

#Preview("Basic") {
    CategoryCapsuleNew(
        category: LandmarkCategory(name: "Beer Gardens"),
        canToggle: false,
        action: nil
    )
}

#Preview("Delete") {
    
    @Previewable @State var isDeleted = false
    
    if isDeleted {
        Image(systemName: "trash")
            .resizable()
            .frame(width: 60, height: 60)
    } else {
        CategoryCapsuleNew(
            category: LandmarkCategory(name: "Golf"),
            canToggle: false,
            action: CategoryCapsuleNew.Action(
                systemImage: "x.circle",
                onTap: { category in
                    withAnimation {
                        isDeleted = true
                    }
                }
            )
        )
    }
}

#Preview("Toggle") {
    
    @Previewable @State var category = LandmarkCategory(name: "Groceries")
    
    CategoryCapsuleNew(
        category: category,
        canToggle: true,
        action: nil
    )
    
    Text(category.isSelected ? "Selected" : "Not selected")
    
}

#endif // DEBUG
