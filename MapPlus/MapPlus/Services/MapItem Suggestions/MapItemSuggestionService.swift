//
//  MapItemSuggestionService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 6/7/26.
//


import MapKit
import FoundationModels

// TODO patmcg doc
protocol MapItemSuggestionService {
    func suggestions(for mapItem: MKMapItem) async throws -> MapItemSuggestions
}
