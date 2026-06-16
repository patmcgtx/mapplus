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
