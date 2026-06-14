//
//  PointOfInterestService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 6/14/26.
//
import Foundation
import MapKit

/// A service that find points of interest (e.g. businesses) near a location.
protocol PointOfInterestService {

    /// Finds points of interest near the given location and radius
    /// - Parameter coordinate: The center of the search location
    /// - Parameter radiusMeters: How wide of a radius to search, in meters
    /// - Returns: Zero or more map items near the given parameters
    func pointsOfInterest(
        near coordinate: CLLocationCoordinate2D,
        radiusMeters: CLLocationDistance
    ) async -> [MKMapItem]

}


