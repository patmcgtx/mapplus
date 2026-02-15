//
//  LocationService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/12/26.
//
import Foundation

/// An async protocol for obtaining the user's current location.
protocol LocationService {
    
    /// Gets the user's current location and converts it to a common `AddressInfo` value.
    /// - Returns: An `AddressInfo` value containing the formatted address and coordinates.
    func getCurrentLocation() async throws -> AddressInfo
}
