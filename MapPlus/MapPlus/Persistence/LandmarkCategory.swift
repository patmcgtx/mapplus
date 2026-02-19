//
//  LandmarkCategory.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/19/26.
//

import SwiftData

/// A named, colored grouping for landmarks (e.g. "Coffee Shops", "Family").
@Model
class LandmarkCategory: Identifiable, Hashable {

    /// The display name of this category
    var name: String

    /// The color of this category stored as a CSS-style hex string, e.g. `"#FF5733"`
    var colorHex: String

    /// The landmarks that belong to this category
    @Relationship(inverse: \Landmark.categories)
    var landmarks: [Landmark] = []

    init(name: String, colorHex: String) {
        self.name = name
        self.colorHex = colorHex
    }
}
