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

    private let standardSession: LanguageModelSession
    private let taggingSession: LanguageModelSession
    
    init () {
        self.standardSession = LanguageModelSession()
        let taggingModel = SystemLanguageModel(useCase: .contentTagging)
        self.taggingSession = LanguageModelSession(model: taggingModel)
    }

    func suggestions(for mapItem: MKMapItem) async throws -> MapItemSuggestions {
        let prompt = """
                Generate suggestions for map item \(mapItem.name ?? "unknown location") 
                in \(mapItem.addressRepresentations?.cityWithContext(.full) ?? "unknown city")
                """
        let response = try await standardSession.respond(
            to: prompt,
            generating: MapItemSuggestions.self
        )
        return response.content
    }

    func categories(for mapItem: MKMapItem) async throws -> [String] {
        
        let prompt = """
                Categories for map item \(mapItem.name ?? "unknown location") 
                in \(mapItem.addressRepresentations?.cityWithContext(.full) ?? "unknown city").
                Suggested categories: '1990s', 'bars', 'breakfast', 'cafes', 'family', 'fun',
                'history', 'lunch', 'music', 'nature', 'open early', 'open late', 'work'
                """
        
        let response = try await taggingSession.respond(
            to: prompt,
            generating: MapItemCategorySuggestions.self
        )
        
        let result: MapItemCategorySuggestions = response.content        
        return result.businessType + result.moods + result.activities + result.settings
    }
}
