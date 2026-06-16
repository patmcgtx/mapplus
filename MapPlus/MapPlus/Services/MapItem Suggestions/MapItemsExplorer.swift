//
//  MapItemsExplorer.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 6/6/26.
//
import Foundation
import MapKit

///A stateful service to iterate through an array of map items with suggestions embedded.
struct MapItemsExplorer {
    
    // MARK: Private properties
    
    private var mapItems: [MKMapItem]
    private var suggestionService: MapItemSuggestionService
    private var pointOfInterestService: PointOfInterestService
 
    private var iterator: IndexingIterator<[MKMapItem]>

    // MARK: Init
    
    /// Creates an instance for the given map items.
    /// - Parameter mapItems: The maps items to iterate through
    init(
        suggestionService: MapItemSuggestionService,
        pointOfInterestService: PointOfInterestService,
        mapItems: [MKMapItem]
    ) {
        self.mapItems = mapItems
        self.iterator = mapItems.makeIterator()
        self.suggestionService = suggestionService
        self.pointOfInterestService = pointOfInterestService
    }
    
    // MARK: Actions
    
    /// Iterates to the next location info, complete with embedded suggestions from local AI and MapKit.
    ///
    /// This method must be called to get the first map item.
    ///
    /// - Returns:The next LocationInfo object or `nil` if no more are available
    mutating func nextMapItem() async -> LocationInfo? {
        guard let mapItem = iterator.next()
        else { return nil }
        
        let poiMapItem = await pointOfInterestService.pointsOfInterest(
            near: mapItem.location.coordinate,
            radiusMeters: 10.0
        ).first
        
        guard let suggestions = try? await suggestionService.suggestions(for: mapItem)
        else { return nil }
        
        return LocationInfo(
            briefDescription: poiMapItem?.name ?? suggestions.name,
            fullDescription: poiMapItem?.fullDescription ?? mapItem.fullDescription,
            coordinates: mapItem.location.coordinate,
            suggestedNotes: suggestions.notes,
            suggestedSymbol: suggestions.symbol
        )
    }

}
