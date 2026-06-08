//
//  MapItemsExplorer.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 6/6/26.
//
import MapKit

///A stateful service to iterate through an array of map items with suggestions embedded.
struct MapItemsExplorer {

    private var mapItems: [MKMapItem]
    private var iterator: IndexingIterator<[MKMapItem]>
    private var suggestionService: MapItemSuggestionService
    
    /// Creates an instance for the given map items.
    /// - Parameter mapItems: The maps items to iterate through
    init(suggestionService: MapItemSuggestionService, mapItems: [MKMapItem]) {
        self.mapItems = mapItems
        self.iterator = mapItems.makeIterator()
        self.suggestionService = suggestionService
    }
        
    /// Iterates to the next location info, complete with embedded AI suggestions.
    ///
    /// This method must be called to get the first map item.
    /// 
    /// - Returns:The next LocationInfo object or `nil` if no more are available
    mutating func nextMapItem() async -> LocationInfo? {
        guard let mapItem = iterator.next(),
              let suggestions = try? await suggestionService.suggestions(for: mapItem)
        else { return nil }
        return LocationInfo(
            briefDescription: mapItem.name ?? suggestions.name,
            fullDescription: mapItem.fullDescription,
            coordinates: mapItem.location.coordinate,
            suggestedNotes: suggestions.notes,
            suggestedSymbol: suggestions.symbol
        )
    }
}
