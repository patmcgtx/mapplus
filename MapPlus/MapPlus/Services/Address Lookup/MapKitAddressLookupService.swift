//
//  MapKitAddressLookupService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/6/26.
//
import MapKit

// TODO patmcg cleanup docs

/// A service for performing asynchronous address lookups using MapKit.
/// Used throughout MapPlus to resolve user-entered locations into structured data.
struct MapKitAddressLookupService: AddressLookupService {
    
    /// Provides lookup functionality for converting address strings into geographic coordinates and descriptions, using MapKit's local search capabilities.
    /// Converts a user-supplied address string into an AddressInfo object, or throws if no address could be found.
    /// - Parameter address: The address or place name to search for, expressed as a user-friendly string.
    /// - Returns: An AddressInfo object containing a formatted description and coordinates of the first found location.
    /// - Throws: MapPlusError.noAddressFound if no matching address or coordinates can be found.
    func lookup(address: String) async throws -> LocationInfo {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = address
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        guard let item = response.mapItems.first else {
            throw MapPlusError.noAddressFound
        }
        let coordinate = item.location.coordinate
        if !CLLocationCoordinate2DIsValid(coordinate) {
            throw MapPlusError.noAddressFound
        }
        return LocationInfo(
            formattedDescription: item.fullDescription,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
    }
}
