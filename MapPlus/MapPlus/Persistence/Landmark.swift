//
//  Landmark
//  MapPlus
//
//  Created by Patrick McGonigle on 10/15/25.
//

import SwiftData
import MapKit

/// Represents one point of interested on the map.
@Model
class Landmark: Identifiable, Hashable {

    /// Every unique point is defined by its coordinates
    #Unique<Landmark>([\.latitude, \.longitude])

    /// A short, descriptive name of this landmark, e.g. "Cosmic Coffee"
    var name: String
    
    /// Optional descriptive notes for a landmark
    var notes: String = ""

    /// And emoji representing the landamrk
    var emoji: String
    
    /// The full address description from MapKit
    var formattedAddress: String = ""
    
    /// Coordinate longitude
    var latitude: CLLocationDegrees

    /// Coordinate latitude
    var longitude: CLLocationDegrees
    
    /// Convenience var for coordinates
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    /// Which categories this landmark is in
    var categories: [LandmarkCategory]

    init(
        name: String = "",
        notes: String = "",
        formattedAddress: String = "",
        emoji: String = "📍",
        systemImageName: String = "mappin.circle",
        location: CLLocationCoordinate2D = .init(latitude: 0.0, longitude: 0.0),
        categories: [LandmarkCategory] = []
    ) {
        self.name = name
        self.notes = notes
        self.formattedAddress = formattedAddress
        self.emoji = emoji
        self.latitude = location.latitude
        self.longitude = location.longitude
        self.categories = categories
    }

    /// Creates a copy of the given landmark
    init(from source: Landmark)
    {
        self.name = source.name
        self.notes = source.notes
        self.formattedAddress = source.formattedAddress
        self.emoji = source.emoji
        self.latitude = source.location.latitude
        self.longitude = source.location.longitude
        self.categories = source.categories
    }

}
