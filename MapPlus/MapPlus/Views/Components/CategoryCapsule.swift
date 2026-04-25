//
//  CategoryCapsuleNew.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 4/16/26.
//
import SwiftUI

/// A "capsule" view of a category, such as to be shown in a flow layout of categories.
struct CategoryCapsule: View {

    /// Describes an optional action for the category
    struct Action {
        
        /// System image for an action on the category buttons
        let systemImage: String
        
        /// An action to take when the category button is tapped
        let onTap: (LandmarkCategory) -> Void
    }
    
    @Environment(\.theme) var theme: MapPlusTheme
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    /// Which category to represent - TODO patmcg does this need a BInding?!
    let category: LandmarkCategory

    /// Whether this category can be selected and de-selected
    let isSelectable: Bool
    
    /// An optional action to add to the category
    let action: Action?
        
    // MARK: View

    var body: some View {
        HStack {
            let fontWeight: Font.Weight = isSelectable && !category.isSelected ? .regular : .heavy
            let fontColor: Color = category.isSelected
                ? theme.selectedCapsuleFontColor
                : theme.foregroundColor(for: colorScheme)
            Text(category.name.uppercased())
                .fontWeight(fontWeight)
                .fontDesign(.rounded)
                .foregroundStyle(fontColor)
            
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
            if isSelectable {
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
            if category.isSelected {
                Capsule(style: .circular)
                    .fill(theme.tintColor)
            } else {
                let borderColor = theme.foregroundColor(for: colorScheme)
                Capsule(style: .circular)
                    .strokeBorder(borderColor, lineWidth: 1.0)
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: category.isSelected) { _, _ in
            isSelectable // Sends haptics when tapped and this is a selectable category
        }
    }
}

#if DEBUG

#Preview("Basic") {
    CategoryCapsule(
        category: LandmarkCategory(name: "Beer Gardens"),
        isSelectable: false,
        action: nil
    )
}

#Preview("Delete") {
    
    CategoryCapsule(
        category: LandmarkCategory(name: "Golf"),
        isSelectable: false,
        action: CategoryCapsule.Action(
            systemImage: "x.circle",
            onTap: { category in }
        )
    )
}

#Preview("Toggle") {
    
    @Previewable @State var category = LandmarkCategory(name: "Groceries")
    
    CategoryCapsule(
        category: category,
        isSelectable: true,
        action: nil
    )
    
    Text(category.isSelected ? "Selected" : "Not selected")
    
}

#endif // DEBUG
