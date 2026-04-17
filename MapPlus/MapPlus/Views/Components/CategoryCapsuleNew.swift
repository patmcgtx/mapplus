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
    struct CategoryAction {
        /// System image for an action on the category buttons
        let systemImage: String
        /// An action to take when the category button is tapped
        let action: (LandmarkCategory) -> Void
    }

    /// Which category to represent
    let category: LandmarkCategory
    
    /// An optional action to add to the category
    let categoryAction: CategoryAction?

    var body: some View {
        HStack {
            let fontWeight: Font.Weight = category.isSelected ? .black : .bold
            Text(category.name.uppercased())
                .fontWeight(fontWeight)
                .fontDesign(.rounded)
                .shadow(radius: 1.0)
            
            if let categoryAction = categoryAction {
                Button(action: {
                }, label: {
                    Image(systemName: categoryAction.systemImage)
                })
                .onTapGesture {
                    withAnimation(.bouncy) {
                        categoryAction.action(category)
                    }
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
                .strokeBorder(lineWidth: 2)
        }
    }
}
