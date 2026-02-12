//
//  CurrentLocationService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/12/26.
//
import CoreLocation
import MapKit

/// A service for obtaining the user's current location and converting it to an AddressInfo.
/// Uses CLLocationManager to get the current coordinates and reverse geocoding to get a formatted address.
class CurrentLocationService: NSObject, CurrentLocationProtocol, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /// Gets the user's current location and converts it to an AddressInfo object.
    /// - Returns: An AddressInfo object containing the formatted address and coordinates.
    /// - Throws: MapPlusError.noAddressFound if location cannot be determined or reverse geocoding fails.
    func getCurrentLocation() async throws -> AddressInfo {
        // First, get the current coordinates
        let location = try await requestCurrentLocation()
        
        // Then, reverse geocode to get a formatted address
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        
        guard let placemark = placemarks.first else {
            throw MapPlusError.noAddressFound
        }
        
        // Build a formatted address string
        let formattedAddress = formatPlacemark(placemark)
        
        return AddressInfo(
            formattedDescription: formattedAddress,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
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
    
    private func formatPlacemark(_ placemark: CLPlacemark) -> String {
        var components: [String] = []
        
        if let name = placemark.name {
            components.append(name)
        }
        if let locality = placemark.locality {
            components.append(locality)
        }
        if let administrativeArea = placemark.administrativeArea {
            components.append(administrativeArea)
        }
        if let country = placemark.country {
            components.append(country)
        }
        
        return components.isEmpty ? "Current Location" : components.joined(separator: ", ")
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
