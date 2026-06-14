//
//  CurrentLocationService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/12/26.
//
import CoreLocation
import MapKit

/// A service for obtaining the user's current location and converting it to an `AddressInfo`.
class MapKitLocationService: NSObject, LocationService, CLLocationManagerDelegate {
    
    // MARK: Private properties
    
    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?
    
    // MARK: Init
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // MARK: LocationService
    
    /// Finds map items near the user's current location
    /// - Returns: Zero or more MapKit map items nearby
    func nearbyMapItems() async throws -> [MKMapItem] {
        let location = try await requestCurrentLocation()
        let request = MKReverseGeocodingRequest(location: location)
        return (try? await request?.mapItems) ?? []
    }

    // TODO patmcg To extract actual business names or points of interest from coordinates, you must use MKLocalPointsOfInterestRequest or MKLocalSearch

    /*
    func fetchBusinessName(from coordinate: CLLocationCoordinate2D) async -> String? {
        // 1. Create a circular region around your coordinate (e.g., 20 meters radius)
        let request = MKLocalPointsOfInterestRequest(center: coordinate, radius: 20)
        
        // Optional: Filter for specific types of businesses if needed
        // request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.restaurant, .cafe, .store])
        
        let search = MKLocalPointsOfInterestSearch(request: request)
        
        do {
            // 2. Fetch the points of interest from Apple Maps
            let response = try await search.start()
            
            // 3. The response contains an array of MKMapItems
            // Grab the closest map item that represents an actual point of interest
            if let nearestBusiness = response.mapItems.first {
                return nearestBusiness.name // This will return "Starbucks", "Target", etc.
            }
        } catch {
            print("Failed to fetch points of interest: \(error.localizedDescription)")
        }
        
        return nil
    }
     */

    // MARK: - Private Helpers
    
    private func requestCurrentLocation() async throws -> CLLocation {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            // Check authorization status
            let status = locationManager.authorizationStatus
            
            switch status {
            case .notDetermined:
                // Request permission first
                locationManager.requestWhenInUseAuthorization()
                // The delegate will be called and we'll retry after authorization
            case .authorizedWhenInUse, .authorizedAlways:
                // We have permission, request location
                locationManager.requestLocation()
            case .restricted, .denied:
                continuation.resume(throwing: MapPlusError.noAddressFound)
                self.continuation = nil
            @unknown default:
                continuation.resume(throwing: MapPlusError.noAddressFound)
                self.continuation = nil
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            continuation?.resume(throwing: MapPlusError.noAddressFound)
            continuation = nil
            return
        }
        
        continuation?.resume(returning: location)
        continuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(throwing: MapPlusError.noAddressFound)
        continuation = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // After authorization changes, check if we should request location
        if continuation != nil {
            let status = manager.authorizationStatus
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                // We have permission now, request location
                manager.requestLocation()
            case .restricted, .denied:
                continuation?.resume(throwing: MapPlusError.noAddressFound)
                continuation = nil
            case .notDetermined:
                // Still waiting for user response
                break
            @unknown default:
                continuation?.resume(throwing: MapPlusError.noAddressFound)
                continuation = nil
            }
        }
    }
}
