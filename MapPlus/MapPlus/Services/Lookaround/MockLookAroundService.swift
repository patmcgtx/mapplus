//
//  MockLookAroundService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/15/26.
//
import MapKit

struct MockLookAroundService: LookAroundService {
    
    /// Provides a local, in-memory mock `LookAroundService` implementation for development and testing.
    func lookAroundScene(for location: CLLocationCoordinate2D) async throws -> MKLookAroundScene? {
        return nil
    }
    
    
}
