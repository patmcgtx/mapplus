//
//  AIMapItemSuggestionService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 6/7/26.
//

import MapKit
import FoundationModels

/// A local AI implementation of the map item suggestion service
final class AIMapItemSuggestionService: MapItemSuggestionService {

    private let session = LanguageModelSession()

    func suggestions(for mapItem: MKMapItem) async throws -> MapItemSuggestions {
        let prompt = "Generate suggestions for map item: \(mapItem.name ?? "unknown location") at \(mapItem.address?.fullAddress ?? "unknown address")"
        let response = try await session.respond(
            to: prompt,
            generating: MapItemSuggestions.self
        )
        return response.content
    }

}
