//
//  CLLocationExtensions.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/13/26.
//
import CoreLocation

extension CLLocation {

    /// Creates a user-facing string with this location's latitude & longitude,
    /// formatted to 5 decimal places just like  Maps. ;-)
    var coordinateString: String {
        coordinateString(locale: Locale.current)
    }
    
    /// Creates a user-facing string with this location's latitude & longitude,
    /// formatted to 5 decimal places with a specific locale.
    /// - Parameter locale: The locale to use for formatting
    /// - Returns: A formatted coordinate string using the locale's list separator
    func coordinateString(locale: Locale) -> String {
        let coordinateFormatter = NumberFormatter()
        coordinateFormatter.numberStyle = .decimal
        coordinateFormatter.locale = locale
        coordinateFormatter.minimumFractionDigits = 5
        coordinateFormatter.maximumFractionDigits = 5
        
        let listFormatter = ListFormatter()
        listFormatter.locale = locale
        
        let lat = NSNumber(value: self.coordinate.latitude)
        let lon = NSNumber(value: self.coordinate.longitude)
        let coordinates = [
            coordinateFormatter.string(from: lat) ?? "--",
            coordinateFormatter.string(from: lon) ?? "--",
        ]
        
        return listFormatter.string(from: coordinates) ?? coordinates.joined(separator: ", ")
    }

}
