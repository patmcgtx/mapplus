//
//  MapPlusError.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//

/// Errors used throughout the app.
enum MapPlusError: Error {

    /// Indicates that a lookup (for example, reverse geocoding or address parsing)
    /// returned no address for the provided input.
    case noAddressFound
    
    /// A human-readable description of the error.
    var errorMessage: String {
        // TODO patmcg localize
        switch self {
        case .noAddressFound:
            return "No address found"
        }
    }
}
