//
//  MapItemSuggestions.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 6/5/26.
//
import MapKit
import FoundationModels

/// AI-generated data for a map item
@Generable(description: "Additional generated information for a location")
struct MapItemSuggestions {

    @Guide(description: "A brief name for the location, ideally 1-3 words")
    let name: String

    @Guide(description: "Some notes on the location, ideally 1-3 sentences")
    let notes: String

    @Guide(description: "A single emoji to represent the location")
    let symbol: String
}

@Generable
struct MapItemCategorySuggestions {
    
    @Guide(description: "Potential categories for the location")
    
    @Guide(
        description: "Most important business types in the input text, for example categories like 'Restaurant', 'Café', 'Hotel', 'Gym', etc.",
        .maximumCount(5)
    )
    let businessType: [String]

    @Guide(
        description: "Most important moods in the input text, for example categories like 'Fun', 'Retro', 'Comforting', 'Classy', 'Romantic', etc.",
        .maximumCount(5)
    )
    let moods: [String]

    @Guide(
        description: "Most important activities in the input text, for example categories like 'Date', 'Studying', 'Yoga', etc.",
        .maximumCount(5)
    )
    let activities: [String]

    @Guide(
        description: "Most important settings in the input text, for example categories like 'Outdoors', 'Nature', 'Sunny', 'Beach', etc.",
        .maximumCount(5)
    )
    let settings: [String]

}
