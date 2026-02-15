//
//  AddressInfo.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//

import CoreLocation

/// A model representing a geographic location, including a display description and coordinates.
/// Used across layers of the app as a common in-memory representation of a location.
struct LocationInfo {
    
    /// A user-friendly, formatted description of the address or point of interest.
    let formattedDescription: String
    
    /// The coordinates of the location
    let coordinates: CLLocationCoordinate2D

    /// Creates a `LocationInfo` instance with the specified description and coordinates.
    /// - Parameters:
    ///   - formattedDescription: A user-friendly string describing the address or point (e.g., a formatted address or place name).
    ///   - coordinates: The coordinates of the location, to populate
    init(
        formattedDescription: String = "",
        coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(
            latitude: 0.0,
            longitude: 0.0
        )
    ) {
        self.formattedDescription = formattedDescription
        self.coordinates = coordinates
    }

    /// Creates a `LocationInfo` instance with the specified description and lat/lon.
    /// - Parameters:
    ///   - formattedDescription: A user-friendly string describing the address or point (e.g., a formatted address or place name).
    ///   - latitude: The latitude of the location, in degrees.
    ///   - longitude: The longitude of the location, in degrees.
    init(
        formattedDescription: String = "",
        latitude: CLLocationDegrees,
        longitude: CLLocationDegrees
    ) {
        self.formattedDescription = formattedDescription
        self.coordinates = CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
}
