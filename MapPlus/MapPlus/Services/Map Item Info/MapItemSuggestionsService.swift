//
//  MapItemSuggestionsService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 6/7/26.
//

import MapKit

/// A service that provides AI-generated suggestions for map items
protocol MapItemSuggestionsService {
    
    /// Generates suggestions for a given map item
    /// - Parameter mapItem: The map item to generate suggestions for
    /// - Returns: Suggestions including name, symbol, and notes
    /// - Throws: An error if suggestions cannot be generated
    func suggestions(for mapItem: MKMapItem) async throws -> MapItemSuggestions
}

/// The production implementation using FoundationModels
struct AIMapItemSuggestionsService: MapItemSuggestionsService {
    
    func suggestions(for mapItem: MKMapItem) async throws -> MapItemSuggestions {
        try await mapItem.suggestions
    }
}

/// A mock implementation for testing
struct MockMapItemSuggestionsService: MapItemSuggestionsService {
    
    private let mockSuggestions: MapItemSuggestions?
    private let shouldSucceed: Bool
    
    /// Creates a mock suggestions service
    /// - Parameters:
    ///   - mockSuggestions: Custom suggestions to return, or nil to use defaults
    ///   - shouldSucceed: Whether the service should succeed or throw an error
    init(
        mockSuggestions: MapItemSuggestions? = nil,
        shouldSucceed: Bool = true
    ) {
        self.mockSuggestions = mockSuggestions
        self.shouldSucceed = shouldSucceed
    }
    
    func suggestions(for mapItem: MKMapItem) async throws -> MapItemSuggestions {
        guard shouldSucceed else {
            throw MapPlusError.noAddressFound
        }
        
        if let mockSuggestions = mockSuggestions {
            return mockSuggestions
        }
        
        // Generate default mock suggestions based on the map item
        let name = mapItem.name ?? "Unknown Location"
        let symbol = determineSymbol(for: mapItem)
        let notes = "Mock notes for \(name)"
        
        return MapItemSuggestions(
            name: name,
            notes: notes,
            symbol: symbol
        )
    }
    
    private func determineSymbol(for mapItem: MKMapItem) -> String {
        // Simple heuristic based on name
        guard let name = mapItem.name?.lowercased() else { return "📍" }
        
        if name.contains("apple") { return "🍎" }
        if name.contains("park") { return "🌳" }
        if name.contains("bridge") { return "🌉" }
        if name.contains("restaurant") || name.contains("cafe") { return "🍽️" }
        if name.contains("hotel") { return "🏨" }
        if name.contains("airport") { return "✈️" }
        if name.contains("beach") { return "🏖️" }
        if name.contains("museum") { return "🏛️" }
        if name.contains("school") || name.contains("university") { return "🎓" }
        if name.contains("hospital") { return "🏥" }
        if name.contains("library") { return "📚" }
        if name.contains("stadium") || name.contains("arena") { return "🏟️" }
        
        return "📍"
    }
}
