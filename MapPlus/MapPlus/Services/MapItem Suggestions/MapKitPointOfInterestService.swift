//
//  MapKitPointOfInterestService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 6/14/26.
//
import Foundation
import MapKit

/// A live MapKit-based point-of-interest search service
class MapKitPointOfInterestService: PointOfInterestService {
    
    func pointsOfInterest(
        near coordinate: CLLocationCoordinate2D,
        radiusMeters: CLLocationDistance = 50
    ) async -> [MKMapItem] {
        
        let request = MKLocalPointsOfInterestRequest(center: coordinate, radius: radiusMeters)
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.restaurant, .cafe, .store])
        
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            return response.mapItems
        } catch {
            // TODO patmcg error handling
            return []
        }
    }
}
