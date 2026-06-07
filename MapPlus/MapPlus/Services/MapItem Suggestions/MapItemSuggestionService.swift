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
}

/// A basic map items suggestion service that returns simple, predictable results.
///
/// Intended for devices that need consistent results or don't support local AI.
struct BasicMapItemSuggestionService: MapItemSuggestionService {
    
    func suggestions(for mapItem: MKMapItem) async throws -> MapItemSuggestions {
        return MapItemSuggestions(
            name: mapItem.name ?? "",
            notes: "",
            symbol: "📍"
        )
    }
}
