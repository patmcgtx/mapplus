//
//  MapKitLookaroundSceneService.swift
//  MapPlus
//
//  Created by Copilot on 2/10/26.
//
import MapKit

/// A service for fetching MapKit LookAround scenes using MapKit's native APIs.
/// Used throughout MapPlus to retrieve street-level imagery for locations.
struct MapKitLookaroundSceneService: LookaroundSceneProtocol {
    
    /// Fetches a LookAround scene for the specified coordinate using MapKit's scene request API.
    /// - Parameter coordinate: The coordinate for which to retrieve the LookAround scene.
    /// - Returns: An MKLookAroundScene object if available, or nil if no scene exists for the location.
    /// - Throws: An error if the scene request fails (e.g., network issues).
    func fetchLookaroundScene(for coordinate: CLLocationCoordinate2D) async throws -> MKLookAroundScene? {
        let sceneRequest = MKLookAroundSceneRequest(coordinate: coordinate)
        return try await sceneRequest.scene
    }
}
