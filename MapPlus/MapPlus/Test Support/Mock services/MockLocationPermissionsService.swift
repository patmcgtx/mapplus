//
//  MockLocationPermissionsService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 6/13/26.
//

#if DEBUG

import MapKit

/// A flexible mock implementation of `LocationPermissionsService` for testing
class MockLocationPermissionsService: LocationPermissionsService {
    
    /// The authorization status to return when permissions are requested
    var statusToReturn: CLAuthorizationStatus = .authorizedWhenInUse
    
    /// Whether to simulate a delay before calling the callback
    var simulateDelay: Bool = false
    
    /// The delay duration in seconds (if simulateDelay is true)
    var delayDuration: TimeInterval = 0.1
    
    /// Tracks whether requestPermissions was called
    private(set) var requestPermissionsCalled = false
    
    /// Tracks the number of times requestPermissions was called
    private(set) var requestPermissionsCallCount = 0
    
    /// The most recent callback passed to requestPermissions
    private(set) var lastCallback: ((_ status: CLAuthorizationStatus) -> Void)?
    
    /// Initialize with a specific status to return
    init(statusToReturn: CLAuthorizationStatus = .authorizedWhenInUse) {
        self.statusToReturn = statusToReturn
    }
    
    func requestPermissions(callback: @escaping (CLAuthorizationStatus) -> Void) {
        requestPermissionsCalled = true
        requestPermissionsCallCount += 1
        lastCallback = callback
        
        if simulateDelay {
            Task {
                try? await Task.sleep(for: .seconds(delayDuration))
                callback(statusToReturn)
            }
        } else {
            callback(statusToReturn)
        }
    }
    
    /// Manually trigger the callback with a specific status (useful for testing status changes)
    func triggerCallback(with status: CLAuthorizationStatus) {
        lastCallback?(status)
    }
    
    /// Reset the mock to its initial state
    func reset() {
        requestPermissionsCalled = false
        requestPermissionsCallCount = 0
        lastCallback = nil
    }
}

#endif // DEBUG
