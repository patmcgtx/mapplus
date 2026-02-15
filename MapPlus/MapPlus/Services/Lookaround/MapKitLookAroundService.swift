//
//  MapKitLookAroundService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/15/26.
//

import MapKit

/// A MapKit-supported service that returns real, working look-around scenes as available.
struct MapKitLookAroundService: LookAroundService {
        
    /// Gets a real live look-around scene from MapKit, if available.
    /// - Parameter location: Which coordinate to get the look-around for
    /// - Returns: A look-around scene object for the location or `nil` if none is available
    func lookAroundScene(for location: CLLocationCoordinate2D) async throws -> MKLookAroundScene? {
        let lookAroundRequest = MKLookAroundSceneRequest(coordinate: location)
        return try await lookAroundRequest.scene
    }

}
