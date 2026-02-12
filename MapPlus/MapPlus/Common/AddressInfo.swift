//
//  AddressInfo.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//

import Foundation
import CoreLocation

/// A model representing a geographic address or a point of interest, including a display description and coordinates.
/// Used throughout MapPlus for representing user-selected or retrieved map locations.
struct AddressInfo: Equatable {
    
    /// Creates an `AddressInfo` instance with the specified description and coordinates.
    /// - Parameters:
    ///   - formattedDescription: A user-friendly string describing the address or point (e.g., a formatted address or place name).
    ///   - latitude: The latitude of the location, in degrees.
    ///   - longitude: The longitude of the location, in degrees.
    init(formattedDescription: String = "", latitude: CLLocationDegrees = 0.0, longitude: CLLocationDegrees = 0.0) {
        self.formattedDescription = formattedDescription
        self.latitude = latitude
        self.longitude = longitude
    }

    /// A user-friendly, formatted description of the address or point of interest.
    let formattedDescription: String

    /// The latitude coordinate of the location, in degrees.
    let latitude: CLLocationDegrees

    /// The longitude coordinate of the location, in degrees.
    let longitude: CLLocationDegrees
}
