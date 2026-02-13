//
//  LocationService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/12/26.
//
import Foundation

/// An async protocol for obtaining the user's current location.
/// Implementations can use CLLocationManager, mock data, or other location services.
protocol LocationService {
    
    /// Gets the user's current location and converts it to an AddressInfo object.
    /// - Returns: An AddressInfo object containing the formatted address and coordinates.
    /// - Throws: MapPlusError.noAddressFound if location cannot be determined or reverse geocoding fails.
    func getCurrentLocation() async throws -> AddressInfo
}
