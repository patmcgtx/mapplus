//
//  AddressLookupProtocol.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/6/26.
//
import Foundation

/// A protocol for performing asynchronous address lookups.
protocol AddressLookupService {
    
    /// Converts a user-supplied address string into an AddressInfo object.
    /// - Parameter address: The address or place name to search for, expressed as a user-friendly string.
    /// - Returns: An AddressInfo object containing a formatted description and coordinates of the found location.
    /// - Throws: MapPlusError.noAddressFound if no matching address or coordinates can be found.
    func lookup(address: String) async throws -> LocationInfo
}
