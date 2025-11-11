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
    
    #Unique<Landmark>([\.latitude, \.longitude])
    
    var name: String
    var systemImageName: String
    @Attribute private var latitude: CLLocationDegrees
    @Attribute private var longitude: CLLocationDegrees
    
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    init(name: String, systemImageName: String, location: CLLocationCoordinate2D) {
        self.name = name
        self.systemImageName = systemImageName
        self.latitude = location.latitude
        self.longitude = location.longitude
    }

}
