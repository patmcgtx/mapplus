//
//  LocationService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/11/26.
//
import CoreLocation
import MapKit

// TODO patmcg make protocol-based
// TODO patmcg make this mockable / unit testable
// TODO patmcg try @Observable

/// A stateful, observable service to access the device's location.
class LocationService: NSObject, ObservableObject {

    private let locationManager = CLLocationManager()
    
    /// The user's current location authorization status, if known.  Otherwise, `nil`.
    @Published var authorizationStatus: CLAuthorizationStatus?

    /// The device's current last known location, if known.  Otherwise, `nil`.
    @Published var currentLocation: AddressInfo?
    
    /// Any error state resulting from getting the location.  If no error, this is `nil`.
    @Published var locationError: Error?

    override init() {
        super.init()
        self.locationManager.delegate = self
    }
    
    /// Requests when-in-use location permissions in the background.
    /// Will prompt the user on the UI if needed.
    /// The result shows up later as an update to `authorizationStatus`.
    func requestPermission() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    /// Requests an update to the device's current location in the background.
    /// The results shows up later as an update to `currentLocation`.
    func getCurrentLocation() {
        self.locationManager.requestLocation()
    }
    
}

// Location manager delegate method overrides.
extension LocationService: CLLocationManagerDelegate {
 
    // Got a successful update back from CLLocationManager after calling `requestLocation()`.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Publish this result on the service's properties
        if let loc = locations.first {
            // TODO Add AddressInfo convenience ctor by CLLocation
            let mapItem = MKMapItem(location: loc, address: nil)
            self.currentLocation = AddressInfo(
                formattedDescription: mapItem.fullDescription,
                latitude: loc.coordinate.latitude,
                longitude: loc.coordinate.longitude
            )
            self.locationError = nil
        } else {
            // Note: theoretically could be nil 🤷🏻‍♂️ so nil everything out
            self.currentLocation = nil
            self.locationError = nil
        }
    }
    
    // Got a failure back from CLLocationManager after calling `requestLocation()`.
    // It's important to implement this.  Otherwise, the location request will fail.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        // Publish this result on the service's properties
        self.currentLocation = nil
        self.locationError = error
    }
    
}
