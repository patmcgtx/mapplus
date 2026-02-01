//
//  AddressLookupService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//
import MapKit

// TODO patmcg doc
struct AddressLookupService {
    
    // TODO patmcg doc
    func lookup(address: String) async throws -> AddressInfo {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = address
        
        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        guard let item = response.mapItems.first else {
            throw MapPlusError.noAddressFound
        }

        let coordinate = item.location.coordinate

        // TODO patmcg return kCLLocationCoordinate2DInvalid instead?
        if !CLLocationCoordinate2DIsValid(coordinate) {
            throw MapPlusError.noAddressFound
        }
                
        return AddressInfo(
            formattedDescription: item.fullDescription,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
    }

}
