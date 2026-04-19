//
//  CategoryCapsuleNew.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 4/16/26.
//
import SwiftUI

/// A "capsule" view of a category, such as to be shown in a flow layout of categories.
struct CategoryCapsule: View {

    /// Describes an action for the category
    struct Action {
        
        /// System image for an action on the category buttons
        let systemImage: String
        
        /// An action to take when the category button is tapped
        let onTap: (LandmarkCategory) -> Void
    }
    
    @Environment(\.theme) var theme: MapPlusTheme
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    /// Which category to represent - TODO patmcg does this need a BInding?!
    @Binding var category: LandmarkCategory

    /// Callback when a category is toggles.  A nil value means no toggling.
    let canToggle: Bool
    
    /// An optional action to add to the category
    let action: Action?
        
    // MARK: View

    var body: some View {
        HStack {
            let fontWeight: Font.Weight = canToggle && !category.isSelected ? .regular : .heavy
            let fontColor = category.isSelected ? theme.tintColor : theme.foregroundColor(for: colorScheme)
            Text(category.name.uppercased())
                .fontWeight(fontWeight)
                .fontDesign(.rounded)
                .foregroundStyle(fontColor)
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
            if canToggle {
                withAnimation() {
                    category.isSelected.toggle()
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
            let borderColor = category.isSelected ? theme.tintColor : theme.foregroundColor(for: colorScheme)
            Capsule(style: .circular)
                .strokeBorder(lineWidth: category.isSelected ? 2.0 : 1.0)
                .stroke(borderColor)
        }
    }
}

#if DEBUG

#Preview("Basic") {
    CategoryCapsule(
        category: .constant(LandmarkCategory(name: "Beer Gardens")),
        canToggle: false,
        action: nil
    )
}

#Preview("Delete") {
    
    CategoryCapsule(
        category: .constant(LandmarkCategory(name: "Golf")),
        canToggle: false,
        action: CategoryCapsule.Action(
            systemImage: "x.circle",
            onTap: { category in }
        )
    )
}

#Preview("Toggle") {
    
    @Previewable @State var category = LandmarkCategory(name: "Groceries")
    
    CategoryCapsule(
        category: $category,
        canToggle: true,
        action: nil
    )
    
    Text(category.isSelected ? "Selected" : "Not selected")
    
}

#endif // DEBUG
