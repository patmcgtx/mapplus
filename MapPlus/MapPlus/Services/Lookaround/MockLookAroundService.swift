//  MockLookAroundService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/15/26.
//
//  -> Thanks, Claude Sonnet 4.5
//
import MapKit

/// A mock implementation of LookAroundService for testing and previews.
/// Returns predefined look-around scenes or throws errors based on configuration.
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
        
    /// Gets a mock look-around scene for a given location.
    /// - Parameter location: Which coordinate to get the look-around for
    /// - Returns: A look-around scene object for the location or `nil` if none is available
    /// - Throws: An error if shouldSucceed is false
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
