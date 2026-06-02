//
//  CategoryCapsuleNew.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 4/16/26.
//
import SwiftUI
import SwiftData

/// A "capsule" view of a category, such as to be shown in a flow layout of categories.
struct CategoryCapsule: View {

    /// Describes an optional action for the category
    struct Action {
        
        /// System image for an action on the category buttons
        let systemImage: String
        
        /// An action to take when the category button is tapped
        let onTap: (LandmarkCategory) -> Void
    }
    
    @AppStorage("theme") private var theme: MapPlusTheme = .cupertino
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @Environment(\.modelContext) private var modelContext

    /// Which category to display
    let category: LandmarkCategory

    /// Whether this category can be selected and de-selected
    let isSelectable: Bool
    
    /// An optional action to add to the category
    let action: Action?
    
    // Category selection state
    @Query private var selectedCategories: [SelectedCategories]
    
    private var selectedCategoriesModel: SelectedCategories? {
        selectedCategories.first
    }
    
    private var isSelected: Bool {
        selectedCategoriesModel?.contains(category) ?? false
    }
        
    // MARK: View

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
                    do {
                        try withAnimation {
                            // Get or create the selection model
                            let selectionModel: SelectedCategories
                            if let existing = selectedCategories.first {
                                selectionModel = existing
                            } else {
                                selectionModel = SelectedCategories()
                                modelContext.insert(selectionModel)
                            }
                            
                            // Toggle the category selection
                            selectionModel.toggle(category)
                            
                            // Update and commit the selected state to immediately reflect across
                            // the app. This is part of an opinionated approach that leverages
                            // SwiftData for simple app-wide, reactive persistent state, breaking
                            // somewhat with traditional MVVM for simplicity and responsiveness.
                            // Basically, it works really well. 🤷🏻‍♂️
                            try modelContext.save()
                        }
                    } catch {
                        // TODO patmcg what to do if the persist fails? Show an error alert? 🤔
                        print("Failed to save category selection: \(error)")
                    }
                }
            }
        }
    }
    
    /// Whether or not to show the selection state of the category
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
}

#Preview("View-only, selected") {
    // In the view-only case, we actually don't want to see the selection state.
    CategoryCapsule(
        category: LandmarkCategory(name: "Beer Gardens"),
        isSelectable: false,
        action: nil
    )
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
    
    Text("Is deleted?")
    Text(isDeleted ? "Yes" : "No")
}

#Preview("Toggle") {
    
    let category = LandmarkCategory(name: "Groceries")
    
    CategoryCapsule(
        category: category,
        isSelectable: true,
        action: nil
    )
    .modelContainer(try! ModelContainer.inMemorySampleContainer())
    
    // TODO patmcg this is not reflecting the state change on category; fix
    Text("Check selection in UI")
    
}

#Preview("Toggle, selected") {
    
    let category = LandmarkCategory(name: "Groceries")
    
    CategoryCapsule(
        category: category,
        isSelectable: true,
        action: nil
    )
    .modelContainer(try! ModelContainer.inMemorySampleContainer())
    
    // TODO patmcg this is not reflecting the state change on category; fix
    Text("Check selection in UI")
}

#endif // DEBUG
