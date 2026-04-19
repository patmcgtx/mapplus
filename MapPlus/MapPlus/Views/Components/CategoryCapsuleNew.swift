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
    @Binding var category: LandmarkCategory

    /// Callback when a category is toggles.  A nil value means no toggling.
    let onToggle: ((LandmarkCategory) -> Void)?
    
    /// An optional action to add to the category
    let action: Action?
    
    // MARK: State
    
//    @State private var isSelected: Bool = false
    
    // MARK: View

    var body: some View {
        HStack {
            let fontWeight: Font.Weight = category.isSelected ? .black : .bold
            Text(category.name.uppercased())
                .fontWeight(fontWeight)
                .fontDesign(.rounded)
                .shadow(radius: 1.0)
            
            if let categoryAction = action {
                Button(action: {
                }, label: {
                    Image(systemName: categoryAction.systemImage)
                })
                .onTapGesture {
                    categoryAction.onTap(category)
                }
            }
        }
        .onTapGesture {
            if let onToggle = onToggle {
                withAnimation() {
                    category.isSelected.toggle()
                    onToggle(category)
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
                .strokeBorder(lineWidth: category.isSelected ? 2.0 : 1.0)
        }
    }
}

#if DEBUG

#Preview("Basic") {
    CategoryCapsuleNew(
        category: .constant(LandmarkCategory(name: "Beer Gardens")),
        onToggle: nil,
        action: nil
    )
}

#Preview("Delete") {
    
    CategoryCapsuleNew(
        category: .constant(LandmarkCategory(name: "Golf")),
        onToggle: nil,
        action: CategoryCapsuleNew.Action(
            systemImage: "x.circle",
            onTap: { category in }
        )
    )
}

#Preview("Toggle") {
    
    @Previewable @State var category = LandmarkCategory(name: "Groceries")
    
    CategoryCapsuleNew(
        category: $category,
        onToggle: { _ in },
        action: nil
    )
    
    Text(category.isSelected ? "Selected" : "Not selected")
    
}

#endif // DEBUG
