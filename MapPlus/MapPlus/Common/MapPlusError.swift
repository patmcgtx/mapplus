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
    
    /// Indicates that a map look-around scene is not available for the location specified.
    case noLookAround
    
    /// Indicates that a location has no associated map item information
    case noLocationInfo
    
    /// A human-readable description of the error.
    var errorMessage: String {
        switch self {
        case .noAddressFound:
            return "no-address-found".localized
        case .noLookAround:
            return "no-look-around".localized
        case .noLocationInfo:
            return "no-location-info".localized
        }
    }
}
