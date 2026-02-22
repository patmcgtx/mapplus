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
    
    /// The SF Symbols icon name for this landmark
    var systemImageName: String = "mappin.circle"
    
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
        systemImageName: String = "mappin.circle",
        location: CLLocationCoordinate2D = .init(latitude: 0.0, longitude: 0.0),
        categories: [LandmarkCategory] = []
    ) {
        self.name = name
        self.notes = notes
        self.formattedAddress = formattedAddress
        self.systemImageName = systemImageName
        self.latitude = location.latitude
        self.longitude = location.longitude
        self.categories = categories
    }

}
