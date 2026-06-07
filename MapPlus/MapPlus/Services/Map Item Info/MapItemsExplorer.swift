//
//  MapItemInfoService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 6/6/26.
//
import MapKit

// TODO patmcg add unit tests

///A stateful service to iterate through an array of map items
struct MapItemsExplorer {

    private var mapItems: [MKMapItem]
    private var iterator: IndexingIterator<[MKMapItem]>

    init(mapItems: [MKMapItem]) {
        self.mapItems = mapItems
        self.iterator = mapItems.makeIterator()
    }
        
    /// Iterates to the next location info, complete with embedded AI suggestions.
    ///
    /// This method must be called to get the first map item.
    /// 
    /// - Returns:The next LocationInfo object or `nil` if no more are available
    mutating func nextLocationInfo() async throws -> LocationInfo? {
        guard let mapItem = iterator.next(),
              let suggestions = try? await mapItem.suggestions
        else { throw MapPlusError.noAddressFound }
        return LocationInfo(
            briefDescription: mapItem.name ?? suggestions.name,
            fullDescription: mapItem.fullDescription,
            coordinates: mapItem.location.coordinate,
            suggestedNotes: suggestions.notes,
            suggestedSymbol: suggestions.symbol
        )
    }
}
