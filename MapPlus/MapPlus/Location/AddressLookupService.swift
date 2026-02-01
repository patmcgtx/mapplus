//
//  AddressLookupService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//
import MapKit
//import Contacts

// TODO patmcg doc
struct AddressLookupService {
    
    // TODO patmcg doc
    func lookupOld(address: String) async throws -> AddressInfo {
        try await Task.sleep(nanoseconds: 100_000_000)
        return AddressInfo(formattedDescription: address, latitude: 1.1, longitude: 1.1)
    }

    func lookup(address: String) async throws -> AddressInfo {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = address
        
        // Optional: Constrain search to a specific region
        // request.region = mapView.region

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        guard let item = response.mapItems.first else {
            throw MapPlusError.noAddressFound
        }

        let coordinate = item.placemark.coordinate
        if let formattedAddress = item.addressRepresentations?.fullAddress(includingRegion: false, singleLine: false)
        ?? item.placemark.title ?? address
        
        return AddressInfo(
            formattedDescription: formattedAddress,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
    }

}
