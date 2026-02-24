//
//  LandmarkExtensions.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/16/26.
//
import CoreLocation
import MapKit

/// Helpful extensions to the Landmark persistent type.
extension Landmark {
    
    /// Opens this landmark in the  Maps app, for a full-featured maps experience,
    /// for example to get directions, search, or see surrounding businesses.
    func openInMaps(mapsOptions: [String : Any]? = [:]) {

        let loc = CLLocation(
            latitude: self.location.latitude,
            longitude: self.location.longitude
        )
        let mapItem = MKMapItem(location: loc, address: nil)

        mapItem.name = self.name
        mapItem.openInMaps(launchOptions: mapsOptions)
    }

    var categoriesSorted: [LandmarkCategory] {
        self.categories.sorted(by: { lhs, rhs in
            lhs.name.localizedStandardCompare(
                rhs.name
            ) == .orderedAscending
        })
    }

    /// Add a category and return the new's categories, sorted in their natural order.
    /// - Parameter category: The category to add
    /// - Returns: The new set of categories in re-sorted order
    func addAndSort(category: LandmarkCategory) -> [LandmarkCategory] {
        self.categories.append(category)
        return self.categoriesSorted
    }
    
}
