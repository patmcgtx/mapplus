//
//  CategoryCapsuleNew.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 4/16/26.
//
import SwiftUI

/// A "capsule" view of a category, such as to be shown in a flow layout of categories.
struct CategoryCapsule: View {
    
    // MARK: Properties
    
    /// Which category to display
    let category: LandmarkCategory

    /// Whether this category can be selected and de-selected
    let isSelectable: Bool
    
    /// An optional action to add to the category
    let action: Action?
    
    // MARK: Environment

    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    @Environment(\.categorySelectionService)
    private var categorySelectionService: CategorySelectionService

    // MARK: App storage
    
    @AppStorage(AppStorageKeys.theme.rawValue)
    private var theme: MapPlusTheme = .cupertino
    
    // MARK: Data types
    
    /// Describes an optional action for the category
    struct Action {
        
        /// System image for an action on the category buttons
        let systemImage: String
        
        /// An action to take when the category button is tapped
        let onTap: (LandmarkCategory) -> Void
    }
            
    // MARK: Views

    var body: some View {
        capsuleContent
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
                if shouldShowSelectionState {
                    Capsule(style: .circular)
                        .fill(theme.tintColor)
                } else {
                    let borderColor = theme.foregroundColor(for: colorScheme)
                    Capsule(style: .circular)
                        .strokeBorder(borderColor, lineWidth: 1.0)
                }
            }
            .sensoryFeedback(.impact(weight: .light), trigger: isSelected) { _, _ in
                isSelectable // Sends haptics when tapped and this is a selectable category
            }
    }
    
    @ViewBuilder
    private var capsuleContent: some View {
        HStack {
            let fontWeight: Font.Weight = shouldShowSelectionState ? .heavy : .regular
            
            let fontColor: Color = shouldShowSelectionState
                ? theme.selectedCapsuleFontColor
                : theme.foregroundColor(for: colorScheme)
            
            Text(category.name.uppercased())
                .fontWeight(fontWeight)
                .fontDesign(.rounded)
                .foregroundStyle(fontColor)
            
            if let categoryAction = action {
                Button {
                    categoryAction.onTap(category)
                } label: {
                    Image(systemName: categoryAction.systemImage)
                        .padding(8) // Increase tap target
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("delete".localized)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if isSelectable {
                withAnimation {
                    categorySelectionService.toggle(category)
                }
            }
        }
    }

    // MARK: Private helpers

    private var isSelected: Bool {
        categorySelectionService.isSelected(category)
    }

    private var shouldShowSelectionState: Bool {
        isSelectable && isSelected
    }
}

#if DEBUG

#Preview("View-only") {
    CategoryCapsule(
        category: LandmarkCategory(name: "Beer Gardens"),
        isSelectable: false,
        action: nil
    )
    .injectMockServices()
}

#Preview("View-only, selected") {
    // In the view-only case, we actually don't want to see the selection state.
    CategoryCapsule(
        category: LandmarkCategory(name: "Beer Gardens"),
        isSelectable: false,
        action: nil
    )
    .injectMockServices()
}

#Preview("Delete") {
    
    @Previewable @State var isDeleted: Bool = false
    
    CategoryCapsule(
        category: LandmarkCategory(name: "Golf"),
        isSelectable: false,
        action: CategoryCapsule.Action(
            systemImage: "x.circle",
            onTap: { category in
                isDeleted.toggle()
            }
        )
    )
    .injectMockServices()

    Text("Is deleted?")
    Text(isDeleted ? "Yes" : "No")
}

#Preview("Toggle") {
    CategoryCapsule(category: SampleCategories().cafes, isSelectable: true, action: nil)
        .injectMockServices()
}

#endif // DEBUG
