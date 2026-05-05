//
//  CategorySelectionType.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 5/2/26.
//

/// How to category selection works.
enum CategorySelectionType: String, Codable {
    
    /// Show landmarks with _any_ of the selected categories.
    /// For example "Cafe" and "Open Early" means all cafes and all places that are open early.
    case matchingAny
    
    /// Show landmarks with _all_ of the selected categories.
    /// For example "Cafe" and "Open Early" means only cafes that are open early.
    case matchingAll
}
