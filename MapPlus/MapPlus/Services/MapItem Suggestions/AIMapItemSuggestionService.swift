//
//  AIMapItemSuggestionService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 6/7/26.
//

import MapKit
import FoundationModels

// TODO patmcg doc
struct AIMapItemSuggestionService: MapItemSuggestionService {
    
    func suggestions(for mapItem: MKMapItem) async throws -> MapItemSuggestions {
        let prompt = "Generate suggestions for map item: \(mapItem.name ?? "unknown location") at \(mapItem.address?.fullAddress ?? "unknown address")"
        let sesh = LanguageModelSession()
        let response = try await sesh.respond(
            to: prompt,
            generating: MapItemSuggestions.self
        )
        return response.content
    }

}
