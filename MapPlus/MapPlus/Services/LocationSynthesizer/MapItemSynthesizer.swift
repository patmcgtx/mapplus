//
//  MapItemSynthesizer.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 6/5/26.
//
import MapKit
import FoundationModels

// TODO patmcg doc all
// TODO patmcg addd protocol & mock

@Generable(description: "Additional generated information for a location")
struct LocationAddOns {
    
    @Guide(description: "A brief description of the location, 1-3 sentences")
    let notes: String
    
    @Guide(description: "A single emoji to represent the location")
    let symbol: String
    
//    @Guide(description: "Categories that match the location")
//    let categories: [LandmarkCategory]
}

extension MKMapItem {
        
    var addOns: LocationAddOns {
        get async throws {
            let prompt = "Generate add-ons for map item: \(self.name ?? "unknown location") at \(self.address?.fullAddress ?? "unknown address")"
            let sesh = LanguageModelSession()
            let response = try await sesh.respond(to: prompt, generating: LocationAddOns.self)
            return response.content
        }
    }
}

