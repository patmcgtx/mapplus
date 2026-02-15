//
//  CLLocationExtensions.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/13/26.
//
import CoreLocation

extension CLLocation {

    private static let coordinateFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.minimumFractionDigits = 5
        formatter.maximumFractionDigits = 5
        return formatter
    }()
    
    // Note: Locale is captured at initialization. Locale changes during runtime
    // will require an app restart to take effect, which is standard iOS behavior.
    private static let listFormatter: ListFormatter = {
        let formatter = ListFormatter()
        formatter.locale = Locale.current
        return formatter
    }()
    
    /// Creates a user-facing string with this location's latitude & longitude,
    /// formatted to 5 decimal places just like  Maps. ;-)
    var coordinateString: String {
        let lat = NSNumber(value: self.coordinate.latitude)
        let lon = NSNumber(value: self.coordinate.longitude)
        let coordinates = [
            CLLocation.coordinateFormatter.string(from: lat) ?? "--",
            CLLocation.coordinateFormatter.string(from: lon) ?? "--",
        ]
        
        return CLLocation.listFormatter.string(from: coordinates) ?? coordinates.joined(separator: ", ")
    }

}
