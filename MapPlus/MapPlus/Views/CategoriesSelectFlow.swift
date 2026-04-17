//
//  CategoriesSelectFlow.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 4/16/26.
//

import SwiftUI
import Flow

/// Displays landmark categories, allowing individual ones to be selected or unselected
struct CategoriesSelectFlow: View {
    
    /// The categories to update on edit / delete
    @Binding var categories: [LandmarkCategory]
    
    var body: some View {
        if categories.isEmpty {
            EmptyView()
        } else {
            HFlow {
                // TODO patmcg encapsulate this sorting here???
                ForEach(categories, id: \.id) { category in
                    CategoryCapsule(category: category,
                                    mode: .select,
                                    fromCategories: $categories)
                }
            }
        }
    }
}
