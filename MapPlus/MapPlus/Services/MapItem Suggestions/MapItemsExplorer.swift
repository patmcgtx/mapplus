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
        
        let poiService = PointOfInterestService()
        let poiMapItem = await poiService.fetchBusinesses(near: mapItem.location.coordinate).first
        
        return LocationInfo(
            briefDescription: poiMapItem?.name ?? suggestions.name,
            fullDescription: poiMapItem?.fullDescription ?? mapItem.fullDescription,
            coordinates: mapItem.location.coordinate,
            suggestedNotes: suggestions.notes,
            suggestedSymbol: suggestions.symbol
        )
    }

    class PointOfInterestService {
        
        func fetchBusinesses(
            near coordinate: CLLocationCoordinate2D,
            radius: CLLocationDistance = 50
        ) async -> [MKMapItem] {
            
            // 1. Create your POI request
            let request = MKLocalPointsOfInterestRequest(center: coordinate, radius: radius)
            
            // Optional filter
            request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.restaurant, .cafe, .store])
            
            // 2. Pass the POI request directly into the standard MKLocalSearch object
            let search = MKLocalSearch(request: request)
            
            do {
                // 3. Execute the search
                let response = try await search.start()
                return response.mapItems
            } catch {
                print("POI search failed: \(error.localizedDescription)")
                return []
            }
        }
    }


}
