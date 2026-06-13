//
//  LocationService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/12/26.
//
import MapKit

/// A protocol for obtaining the user's current location.
protocol LocationService {

    /// Finds map items near the user's current location
    /// - Returns: Zero or more MapKit map items nearby
    func nearbyMapItems() async throws -> [MKMapItem]

    /// Gets the user's current location and converts it to a common `LocationInfo` value.
    /// - Returns: A `LocationInfo` value containing the formatted address and coordinates.
    func getCurrentLocation() async throws -> LocationInfo
}
