//
//  MapItemSuggestionService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 6/7/26.
//


import MapKit
import FoundationModels

/// A service that provides suggestions for a map item, i.e. name, icon, etc.
protocol MapItemSuggestionService {
    
    /// Generates suggestions for a map item, i.e. name, icon, etc.
    /// - Parameter mapItem: The map item to process
    /// - Returns: Suggestions for the given map item, i.e. name, icon, etc
    func suggestions(for mapItem: MKMapItem) async throws -> MapItemSuggestions
    
    /// Generates suggested categories  for a map item
    /// - Parameter mapItem: The map item to process
    /// - Returns: Suggestions for the given map item, i.e. name, icon, etc
    func categories(for mapItem: MKMapItem) async throws -> [String]

}

/// A basic map items suggestion service that returns simple, predictable results.
///
/// Intended for devices that don't support local AI or that need consistent results, such as tests.
struct BasicMapItemSuggestionService: MapItemSuggestionService {
    
    func suggestions(for mapItem: MKMapItem) async throws -> MapItemSuggestions {
        return MapItemSuggestions(
            name: mapItem.name ?? "",
            notes: "",
            symbol: "📍"
        )
    }
    
    func categories(for mapItem: MKMapItem) async throws -> [String] {
        return [] // No categories by default
    }
}
