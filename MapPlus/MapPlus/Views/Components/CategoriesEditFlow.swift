//
//  CategoriesEditFlow.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 4/16/26.
//
import SwiftUI
import Flow

/// Displays landmark categories, allowing individual categories to be added or deleted.
struct CategoriesEditFlow: View {
    
    /// The categories list to edit.
    @Binding var categories: [LandmarkCategory]
    
    var body: some View {
        if categories.isEmpty {
            EmptyView()
        } else {
            HFlow {
                ForEach($categories) { category in
                    CategoryCapsule(
                        category: category,
                        onToggle: nil,
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
    CategoriesEditFlow(categories: $categories)
    
}

#endif // DEBUG
