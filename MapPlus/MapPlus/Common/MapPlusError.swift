//
//  MapPlusError.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//
import Foundation

/// Errors used by the MapPlus module.
///  This enum represents the different error conditions that can occur
///  when performing map-related lookups and operations within MapPlus.
enum MapPlusError: LocalizedError {
    
    /// Indicates that a lookup (for example, reverse geocoding or address parsing)
    /// returned no address for the provided input.
    case addressNotFound
    
    /// Indicates the the current locaton cannot be found
    case currentLocationNotFound

    /// Provides a localized error description  per `LocalizedError`
    var errorDescription: String? {
        // TODO patmcg localize
        switch self {
        case .addressNotFound:
            return "No address found"
        case .currentLocationNotFound:
            return "Current location not found"
        }
    }
    
}
