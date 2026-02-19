//
//  CategorySampleData.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/19/26.
//

/// A set of pre-built landmark categories for development and initial data.
struct CategorySampleData {

    var coffeeShops: LandmarkCategory {
        LandmarkCategory(name: "Coffee Shops", colorHex: "#7B4F2E")
    }

    var foodAndDrink: LandmarkCategory {
        LandmarkCategory(name: "Food & Drink", colorHex: "#E07B39")
    }

    var entertainment: LandmarkCategory {
        LandmarkCategory(name: "Entertainment", colorHex: "#7B52AB")
    }

    var family: LandmarkCategory {
        LandmarkCategory(name: "Family", colorHex: "#3A7BD5")
    }

    var work: LandmarkCategory {
        LandmarkCategory(name: "Work", colorHex: "#2E8B57")
    }

    var travel: LandmarkCategory {
        LandmarkCategory(name: "Travel", colorHex: "#1A9E9E")
    }

    var shopping: LandmarkCategory {
        LandmarkCategory(name: "Shopping", colorHex: "#D5567B")
    }

    var health: LandmarkCategory {
        LandmarkCategory(name: "Health", colorHex: "#C0392B")
    }

    /// All initial sample categories
    var all: [LandmarkCategory] {
        [coffeeShops, foodAndDrink, entertainment, family, work, travel, shopping, health]
    }
}
