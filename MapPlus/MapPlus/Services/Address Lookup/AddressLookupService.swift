//
//  AddressLookupProtocol.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/6/26.
//

import MapKit

/// An address search service
protocol AddressLookupService {
    
    /// A text-based location search
    /// - Parameter searchString: A user-provided search string for locations
    func mapItemsFor(searchString: String) async throws -> [MKMapItem]
}
