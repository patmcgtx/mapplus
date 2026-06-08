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




