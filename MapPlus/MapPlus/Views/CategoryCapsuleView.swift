//
//  CategoryCapsuleView.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/19/26.
//

import SwiftUI

/// A colored capsule representing a single landmark category.
///
/// Pass an `onRemove` closure to show a dismiss button for removing the category.
struct CategoryCapsuleView: View {

    let category: LandmarkCategory

    /// When non-nil, a dismiss button is shown and this closure is called when tapped.
    var onRemove: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 4) {
            Text(category.name)
                .font(.caption)
                .fontWeight(.medium)
            if let onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                }
                .accessibilityLabel("remove-category".localized)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(Color(hex: category.colorHex).opacity(0.15))
                .overlay(
                    Capsule().strokeBorder(Color(hex: category.colorHex), lineWidth: 1.5)
                )
        )
        .foregroundStyle(Color(hex: category.colorHex))
    }
}

// MARK: - Previews

#Preview {
    HStack {
        CategoryCapsuleView(
            category: CategorySampleData().coffeeShops
        )
        CategoryCapsuleView(
            category: CategorySampleData().entertainment,
            onRemove: {}
        )
    }
    .padding()
}
