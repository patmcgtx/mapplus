//
//  MapKitLookAroundService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/15/26.
//

import MapKit

struct MapKitLookAroundService: LookAroundService {
        
    func lookAroundScene(for location: CLLocationCoordinate2D) async throws -> MKLookAroundScene? {
        let lookAroundRequest = MKLookAroundSceneRequest(coordinate: location)
        return try await lookAroundRequest.scene
    }

}
