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
    
    /// Creates a user-facing string with this location's latitude & longitude,
    /// formatted to 5 decimal places just like  Maps. ;-)
    var coordinateString: String {
        let lat = NSNumber(value: self.coordinate.latitude)
        let lon = NSNumber(value: self.coordinate.longitude)
        return [
            CLLocation.coordinateFormatter.string(from: lat) ?? "--",
            CLLocation.coordinateFormatter.string(from: lon) ?? "--",
            ]
            .joined(separator: ", ")
    }

}
