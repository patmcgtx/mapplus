//
//  Landmark
//  MapPlus
//
//  Created by Patrick McGonigle on 10/15/25.
//

import SwiftData
import MapKit

@Model
class Landmark: Identifiable, Hashable {

    // Every exact point is unique
    #Unique<Landmark>([\.latitude, \.longitude])

    /// A short, descriptive name of this landmark
    var name: String
    
    /// Descriptive notes for a landmark
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
    
    init(
        name: String = "",
        notes: String = "",
        formattedAddress: String = "",
        systemImageName: String = "mappin.circle",
        location: CLLocationCoordinate2D = .init(latitude: 0.0, longitude: 0.0)
    ) {
        self.name = name
        self.notes = notes
        self.formattedAddress = formattedAddress
        self.systemImageName = systemImageName
        self.latitude = location.latitude
        self.longitude = location.longitude
    }

}
