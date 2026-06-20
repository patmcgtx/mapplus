//
//  CurrentLocationService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/12/26.
//
import MapKit

/// A protocol for obtaining the user's current location.
protocol CurrentLocationService {
    
    /// Finds map items near the user's current location
    /// - Returns: Zero or more MapKit map items nearby
    func nearbyMapItems() async throws -> [MKMapItem]
}
