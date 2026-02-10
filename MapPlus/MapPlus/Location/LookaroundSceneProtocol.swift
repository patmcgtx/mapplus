//
//  LookaroundSceneProtocol.swift
//  MapPlus
//
//  Created by Copilot on 2/10/26.
//
import Foundation
import MapKit

/// A protocol for fetching MapKit LookAround scenes for a given coordinate.
/// Implementations can use MapKit, mock data, or other scene retrieval services.
protocol LookaroundSceneProtocol {
    /// Fetches a LookAround scene for the specified coordinate.
    /// - Parameter coordinate: The coordinate for which to retrieve the LookAround scene.
    /// - Returns: An MKLookAroundScene object if available, or nil if no scene exists for the location.
    /// - Throws: An error if the scene request fails.
    func fetchLookaroundScene(for coordinate: CLLocationCoordinate2D) async throws -> MKLookAroundScene?
}
