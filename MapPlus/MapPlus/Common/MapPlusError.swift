//
//  MapPlusError.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//
import Foundation

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

/// Specific error types for location search operations
enum SearchError: Error, Equatable, LocalizedError {

    // TODO patmcg doc
    case noResults
    case networkUnavailable
    case locationServicesDisabled
    case locationPermissionDenied
    case unknown(String)
    
    // TODO patmcg add localized versions of all these strings
    var errorDescription: String? {
        switch self {
        case .noResults:
            return "search-error-no-results".localized
        case .networkUnavailable:
            return "search-error-network".localized
        case .locationServicesDisabled:
            return "search-error-location-disabled".localized
        case .locationPermissionDenied:
            return "search-error-location-permission".localized
        case .unknown(let message):
            return message
        }
    }
    
    // TODO patmcg add localized versions of all these strings
    var recoverySuggestion: String? {
        switch self {
        case .noResults:
            return "search-error-no-results-suggestion".localized
        case .networkUnavailable:
            return "search-error-network-suggestion".localized
        case .locationServicesDisabled:
            return "search-error-location-disabled-suggestion".localized
        case .locationPermissionDenied:
            return "search-error-location-permission-suggestion".localized
        case .unknown:
            return nil
        }
    }
}
