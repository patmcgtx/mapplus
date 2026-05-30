//
//  CategoriesDeleteFlow.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 4/16/26.
//
import SwiftUI
import Flow

/// Displays landmark categories, allowing individual categories to be deleted.
struct CategoriesDeleteFlow: View {
    
    /// The categories list to edit.
    ///
    /// In this case we use a binding (not a @Query) because we want this editing to be in-memory only.
    /// Only once the user saves the changes, do we commit them.
    @Binding var categories: [LandmarkCategory]
    
    var body: some View {
        if categories.isEmpty {
            EmptyView()
        } else {
            HFlow {
                ForEach($categories) { category in
                    CategoryCapsule(
                        category: category.wrappedValue,
                        isSelectable: false,
                        categorySelection: nil,
                        action: CategoryCapsule.Action(
                                systemImage: "x.circle",
                                onTap: { tappedCategory in
                                    withAnimation(.bouncy) {
                                        categories.removeAll { $0 == tappedCategory }
                                    }
                                }
                            )
                    )
                }
            }
        }
    }
}

#if DEBUG

#Preview {
    
    @Previewable @State var categories: [LandmarkCategory] = [
        LandmarkCategory(name: "One"),
        LandmarkCategory(name: "Two"),
        LandmarkCategory(name: "Three"),
    ]
    
    CategoriesDeleteFlow(categories: $categories)

    let remaining = categories.map{ $0.name }.joined(separator: ", ")
    Text("Remaining: \(remaining)")
}

#endif // DEBUG
