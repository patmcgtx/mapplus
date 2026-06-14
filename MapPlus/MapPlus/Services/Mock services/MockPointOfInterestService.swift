//
//  MockPointOfInterestService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 6/14/26.
//

import Foundation
import MapKit

/// A mock implementation of `PointOfInterestService` for testing and development.
///
/// This mock returns predetermined points of interest without making network requests.
/// You can configure the mock data by setting the `mockItems` property.
final class MockPointOfInterestService: PointOfInterestService {
    
    // MARK: - Properties
    
    /// The mock map items to return from `fetchBusinesses(near:radius:)`.
    /// If nil, generates sample data based on the search location.
    var mockItems: [MKMapItem]?
    
    /// Simulated delay in seconds before returning results (default: 0.5).
    var simulatedDelay: TimeInterval = 0.5
    
    /// If true, the next fetch will return an empty array.
    var shouldReturnEmpty: Bool = false
    
    // MARK: - Initialization
    
    init(mockItems: [MKMapItem]? = nil) {
        self.mockItems = mockItems
    }
    
    // MARK: - PointOfInterestService
    
    func pointsOfInterest(
        near coordinate: CLLocationCoordinate2D,
        radiusMeters radius: CLLocationDistance
    ) async -> [MKMapItem] {
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: UInt64(simulatedDelay * 1_000_000_000))
        
        // Return empty if configured
        if shouldReturnEmpty {
            return []
        }
        
        // Return predefined mock items if available
        if let mockItems = mockItems {
            return mockItems
        }
        
        // Generate sample data near the search location
        return generateSampleBusinesses(near: coordinate, radius: radius)
    }
    
    // MARK: - Private Helpers
    
    private func generateSampleBusinesses(
        near coordinate: CLLocationCoordinate2D,
        radius: CLLocationDistance
    ) -> [MKMapItem] {
        let businesses = [
            ("Coffee Shop", "Cafe"),
            ("Pizza Place", "Restaurant"),
            ("Grocery Store", "Store"),
            ("Gas Station", "Gas Station"),
            ("Bank", "Bank")
        ]
        
        return businesses.enumerated().map { index, business in
            let (name, category) = business
            
            // Create a coordinate offset from the search center
            let offsetLat = coordinate.latitude + (Double(index) * 0.001)
            let offsetLon = coordinate.longitude + (Double(index) * 0.001)
            let businessCoordinate = CLLocationCoordinate2D(
                latitude: offsetLat,
                longitude: offsetLon
            )
            
            // Create a placemark
            let placemark = MKPlacemark(coordinate: businessCoordinate)
            
            // Create a map item
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = name
            mapItem.pointOfInterestCategory = MKPointOfInterestCategory(rawValue: category)
            
            return mapItem
        }
    }
}
