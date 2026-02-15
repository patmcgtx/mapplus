//
//  LookAroundService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/15/26.
//

import MapKit

/// A protocol to obtain a map look-around view.
protocol LookAroundService {

    /// Gets a look-around scene for a given location, if available.
    /// - Parameter location: Which coordinate to get the look-around for
    /// - Returns: A look-around scene object for the location or `nil` if none is available
    func lookAroundScene(for location: CLLocationCoordinate2D) async throws -> MKLookAroundScene?
}
