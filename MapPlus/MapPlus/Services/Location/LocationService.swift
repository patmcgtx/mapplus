//
//  LocationService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/12/26.
//
import MapKit

/// A protocol for obtaining the user's current location.
protocol LocationService {

    // TODO patmcg doc
    func currentLocationInfo() async throws -> [MKMapItem]

    /// Gets the user's current location and converts it to a common `LocationInfo` value.
    /// - Returns: A `LocationInfo` value containing the formatted address and coordinates.
    func getCurrentLocation() async throws -> LocationInfo
}
