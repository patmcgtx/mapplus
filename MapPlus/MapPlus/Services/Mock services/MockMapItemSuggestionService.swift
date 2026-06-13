//
//  MockMapItemSuggestionService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 6/13/26.
//
#if DEBUG
import MapKit

/// A mock suggestion service for testing that returns predefined suggestions
struct MockMapItemSuggestionService: MapItemSuggestionService {
    let notes: String
    let symbol: String
    
    init(notes: String = "", symbol: String = "📍") {
        self.notes = notes
        self.symbol = symbol
    }
    
    func suggestions(for mapItem: MKMapItem) async throws -> MapItemSuggestions {
        return MapItemSuggestions(
            name: mapItem.name ?? "",
            notes: notes,
            symbol: symbol
        )
    }
}
#endif // DEBUG
