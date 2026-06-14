//
//  MapPlusError.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//
import Foundation

/// Errors used throughout the app.
enum MapPlusError: Error, Equatable, LocalizedError {

    /// Indicates that a lookup (for example, reverse geocoding or address parsing)
    /// returned no address for the provided input.
    case noAddressFound
    
    /// Indicates that a map look-around scene is not available for the location specified.
    case noLookAround
    
    /// Indicates that a location has no associated map item information
    case noLocationInfo
    
    /// Indicates that a search returned no results
    case noResults
    
    /// Indicates that network connectivity is unavailable
    case networkUnavailable
    
    /// Indicates that location services are disabled
    case locationServicesDisabled
    
    /// Indicates that location permission was denied
    case locationPermissionDenied
    
    /// An unknown error with a custom message
    case unknown(String)
    
    /// A localized, human-readable description of the error.
    var errorDescription: String? {
        switch self {
        case .noAddressFound:
            return "no-address-found".localized
        case .noLookAround:
            return "no-look-around".localized
        case .noLocationInfo:
            return "no-location-info".localized
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
    
    /// A localized message describing how one might recover from the failure.
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
        default:
            return nil
        }
    }
    
    static func == (lhs: MapPlusError, rhs: MapPlusError) -> Bool {
        switch (lhs, rhs) {
        case (.noAddressFound, .noAddressFound),
             (.noLookAround, .noLookAround),
             (.noLocationInfo, .noLocationInfo),
             (.noResults, .noResults),
             (.networkUnavailable, .networkUnavailable),
             (.locationServicesDisabled, .locationServicesDisabled),
             (.locationPermissionDenied, .locationPermissionDenied):
            return true
        case (.unknown(let lhsMessage), .unknown(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

