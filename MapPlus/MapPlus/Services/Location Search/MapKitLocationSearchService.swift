//
//  MapKitLocationSearchService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/6/26.
//
import MapKit

/// A live MapKit implementation of `AddressLookupService`
struct MapKitLocationSearchService: LocationSearchService {

    func mapItemsFor(searchString: String) async throws -> [MKMapItem] {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchString
        
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        
        return response.mapItems
    }

}

