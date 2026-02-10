//
//  MockLookaroundSceneService.swift
//  MapPlus
//
//  Created by Copilot on 2/10/26.
//
import Foundation
import MapKit

/// A mock implementation of LookaroundSceneProtocol for testing and previews.
/// Returns predefined scenes or nil based on configuration.
struct MockLookaroundSceneService: LookaroundSceneProtocol {
    
    /// Controls whether the mock should return a scene (true) or nil (false).
    var shouldReturnScene: Bool = true
    
    /// Controls whether the mock should throw an error.
    var shouldThrowError: Bool = false
    
    /// Optional custom error to throw instead of a generic error.
    var customError: Error?
    
    /// Performs a mock LookAround scene fetch.
    /// - Parameter coordinate: The coordinate for which to retrieve the scene.
    /// - Returns: A mock MKLookAroundScene object if shouldReturnScene is true, nil otherwise.
    /// - Throws: An error if shouldThrowError is true.
    func fetchLookaroundScene(for coordinate: CLLocationCoordinate2D) async throws -> MKLookAroundScene? {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        if shouldThrowError {
            if let customError = customError {
                throw customError
            }
            throw NSError(domain: "MockLookaroundSceneService", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Mock error: Failed to fetch scene"
            ])
        }
        
        if !shouldReturnScene {
            return nil
        }
        
        // Note: We cannot create a real MKLookAroundScene object in tests as it's not publicly initializable.
        // In practice, this mock should return nil or throw, and UI tests should use the real service.
        // For unit testing, callers should check for nil returns.
        return nil
    }
}
