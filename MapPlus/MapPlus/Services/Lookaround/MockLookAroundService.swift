//  MockLookAroundService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/15/26.
//  Thanks, Claude Sonnet 4.5
//
import MapKit

#if DEBUG

/// A mock implementation of LookAroundService for testing and previews.
struct MockLookAroundService: LookAroundService {
    
    /// Optional error to throw
    let errorToThrow: Error?
        
    /// Optional custom scene to return
    let sceneToReturn: MKLookAroundScene?
    
    /// Network delay to simulate in seconds
    let networkDelaySeconds: Double?
        
    init(
        errorToThrow: Error? = nil,
        sceneToReturn: MKLookAroundScene? = nil,
        networkDelaySeconds: Double? = 0
    ) {
        self.errorToThrow = errorToThrow
        self.sceneToReturn = sceneToReturn
        self.networkDelaySeconds = networkDelaySeconds
    }
        
    /// Mocks a look-around scene result with the configured network delay and resulting in the given return value and/or error.
    /// - Parameter location: Which coordinate to get the look-around for (doesn't matter for this mock)
    /// - Returns: The provided `sceneToReturn`, which may be `nil`
    /// - Throws: The provided `errorToThrow` if non-nil
    func lookAroundScene(for location: CLLocationCoordinate2D) async throws -> MKLookAroundScene? {
        
        if let networkDelaySeconds = networkDelaySeconds {
            try await Task.sleep(for: .seconds(networkDelaySeconds))
        }
        
        if let errorToThrow = errorToThrow {
            throw errorToThrow
        }
        
        return sceneToReturn
    }
}

#endif // DEBUG
