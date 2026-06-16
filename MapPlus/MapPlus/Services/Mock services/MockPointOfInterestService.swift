//
//  MockPointOfInterestService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 6/14/26.
//

#if DEBUG

import Foundation
import MapKit

/// A mock implementation of `PointOfInterestService` for testing and development.
///
/// This mock returns predetermined points of interest without making network requests.
/// You can configure the mock data by setting the `mockItems` property.
final class MockPointOfInterestService: PointOfInterestService {
    
    // MARK: - Properties
    
    /// The mock map items to return from `pointsOfInterest(near:radiusMeters:)`.
    /// If nil, returns an empty array (tests should configure this explicitly).
    var mockItems: [MKMapItem]?
    
    /// Simulated delay in seconds before returning results (default: 0).
    var simulatedDelay: TimeInterval = 0
    
    /// If true, the next fetch will return an empty array.
    var shouldReturnEmpty: Bool = false
    
    // MARK: - Initialization
    
    init(mockItems: [MKMapItem]? = nil, shouldReturnEmpty: Bool = false) {
        self.mockItems = mockItems
        self.shouldReturnEmpty = shouldReturnEmpty
    }
    
    // MARK: - PointOfInterestService
    
    func pointsOfInterest(
        near coordinate: CLLocationCoordinate2D,
        radiusMeters: CLLocationDistance
    ) async -> [MKMapItem] {
        // Simulate network delay
        if simulatedDelay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(simulatedDelay * 1_000_000_000))
        }
        
        // Return empty if configured
        if shouldReturnEmpty {
            return []
        }
        
        // Return predefined mock items if available
        if let mockItems = mockItems {
            return mockItems
        }
        
        // Default: return empty array
        // Tests should explicitly configure mockItems to avoid confusion
        return []
    }
}

#endif // DEBUG
