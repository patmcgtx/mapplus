//  LocationPermissonsService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 11/13/25.
//
import MapKit

// TODO patmcg cleanup docs

/// A protocol for requesting and observing location authorization status.
protocol LocationPermissionsServicing {
    func requestPermissions(callback: @escaping (_ status: CLAuthorizationStatus) -> Void)
}

/// Service that wraps CLLocationManager to request and report location authorization status.
///
/// Use this class to request "When In Use" location permissions and receive the resulting
/// authorization status via a callback. The service sets itself as the CLLocationManager
/// delegate and forwards authorization changes to the provided closure.
///
/// Important:
/// - Ensure your app's Info.plist contains a value for `NSLocationWhenInUseUsageDescription`.
///
/// Behavior notes:
/// - The callback is invoked from the CLLocationManagerDelegate when the authorization
///   status changes (the delegate method `locationManager(_:didChangeAuthorization:)`).
/// - Depending on iOS version and the current authorization state, the delegate method may
///   be called immediately or after the system prompt is presented to the user.
class LocationPermissionsService: NSObject, CLLocationManagerDelegate, LocationPermissionsServicing {
    
    // TODO patmcg can this be folded into LocationService?
    
    private var locationManager = CLLocationManager()
    private var callback: (_ status: CLAuthorizationStatus) -> Void = { status in }
    
    /// Requests "when in use" location permissions as needed.
    ///
    /// The provided `callback` will be invoked when the authorization status changes.
    /// The closure is retained by this service until it is replaced by a subsequent
    /// call to `requestPermissions(callback:)` or the service is deallocated.
    ///
    /// - Parameter callback : A closure to call when the permissions request completes with
    ///   the resulting `CLAuthorizationStatus`.
    func requestPermissions(callback: @escaping (_ status: CLAuthorizationStatus) -> Void) {
        self.callback = callback
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
    }

    // MARK: - CLLocationManagerDelegate

    /// Forward authorization changes from the CLLocationManager to the stored callback.
    ///
    /// This method is part of `CLLocationManagerDelegate` and is called by the system when
    /// the authorization status for location services changes. We simply forward the
    /// `status` value to the user's callback.
    ///
    /// - Note: Depending on iOS version the exact timing and frequency of this delegate
    ///   callback may vary. Keep your callback logic resilient to being called multiple
    ///   times or being called with the current status immediately.
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        callback(status)
    }
}
