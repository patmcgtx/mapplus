//
//  MapItemInfoService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 6/6/26.
//
import MapKit

// TODO patmcg add protocol, mocks, unit tests?

// TODO patmcg doc - a stateful service to iterate through an array of map items
struct MapItemInfoService {

    private var mapItems: [MKMapItem]
    private var iterator: IndexingIterator<[MKMapItem]>

    init(mapItems: [MKMapItem]) {
        self.mapItems = mapItems
        self.iterator = mapItems.makeIterator()
    }
        
    // TODO patmcg doc
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
