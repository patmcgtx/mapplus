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
    
    /// The SF Symbols icon name for this landmark
    var systemImageName: String
    
    /// The full address description from MapKit
    var formattedAddress: String
    
    @Attribute private var latitude: CLLocationDegrees
    @Attribute private var longitude: CLLocationDegrees
    
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    init(
        name: String,
        formattedAddress: String,
        systemImageName: String,
        location: CLLocationCoordinate2D
    ) {
        self.name = name
        self.formattedAddress = formattedAddress
        self.systemImageName = systemImageName
        self.latitude = location.latitude
        self.longitude = location.longitude
    }

}
