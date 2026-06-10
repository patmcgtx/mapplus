//
//  LocationInfo.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//

import CoreLocation
import MapKit

/// A model representing a geographic location, including a display description and coordinates.
/// Used across layers of the app as a common in-memory representation of a location.
struct LocationInfo {

    /// A string briefly describing the location, such as business name, e.g. "Torchy's"
    let briefDescription: String

    /// A string describing the full address of the location
    let fullDescription: String
    
    /// The coordinates of the location
    let coordinates: CLLocationCoordinate2D
    
    /// Generated notes for this location
    let suggestedNotes: String
    
    /// Generated symbol for this location
    let suggestedSymbol: String
    
    /// The associated raw map item
    let backingMapItem: MKMapItem?

    /// Creates a `LocationInfo` instance with the specified description and coordinates.
    /// - Parameters:
    ///   - briefDescription: A string briefly describing the location, such as business name, e.g. "Torchy's"
    ///   - fullDescription: A string describing the full address of the location
    ///   - coordinates: The coordinates of the location, to populate
    init(
        briefDescription: String,
        fullDescription: String = "",
        coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(
            latitude: 0.0,
            longitude: 0.0
        ),
        suggestedNotes: String = "",
        suggestedSymbol: String = "📍",
        backingMapItem: MKMapItem?
    ) {
        self.briefDescription = briefDescription
        self.fullDescription = fullDescription
        self.coordinates = coordinates
        self.suggestedNotes = suggestedNotes
        self.suggestedSymbol = suggestedSymbol
        self.backingMapItem = backingMapItem
    }

    /// Creates a `LocationInfo` instance with the specified description and lat/lon.
    /// - Parameters:
    ///   - briefDescription: A string briefly describing the location, such as business name, e.g. "Torchy's"
    ///   - fullDescription: A string describing the full address of the location
    ///   - latitude: The latitude of the location, in degrees.
    ///   - longitude: The longitude of the location, in degrees.
    init(
        briefDescription: String,
        fullDescription: String = "",
        latitude: CLLocationDegrees,
        longitude: CLLocationDegrees,
        suggestedNotes: String = "",
        suggestedSymbol: String = "📍",
        backingMapItem: MKMapItem?
    ) {
        self.briefDescription = briefDescription
        self.fullDescription = fullDescription
        self.coordinates = CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
        self.suggestedNotes = suggestedNotes
        self.suggestedSymbol = suggestedSymbol
        self.backingMapItem = backingMapItem
    }
}

