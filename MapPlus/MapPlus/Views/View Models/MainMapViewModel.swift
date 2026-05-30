//
//  MainMapViewModel.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 5/30/26.
//

import SwiftUI
import SwiftData
import MapKit

/// View model that provides state and logic for `MainMapView`.
@Observable @MainActor
final class MainMapViewModel {
    
    // MARK: - UI State
    
    /// Whether the landmarks list sheet is showing
    var showingLandmarkList: Bool = false
    
    /// Whether the add landmark sheet is showing
    var isShowingAddLandmarkSheet: Bool = false
    
    /// Whether the category filter popover is showing
    var isShowingCategoryFilter: Bool = false
    
    /// Used to trigger sensory feedback when locate button is tapped
    var didTapLocate: Bool = false
    
    // MARK: - Map State
    
    /// The current camera position of the map
    var mapPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    /// The currently selected landmark (shows detail sheet)
    var selectedLandmark: Landmark?
    

    
    // MARK: - Preferences
    
    /// The currently active theme
    var activeTheme: MapPlusTheme = .cupertino
    
    /// The current points of interest visibility level
    var activePOILevel: PointsOfInterestLevel = .none
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Public Methods
    
    /// Request location permissions from the user
    /// - Parameter locationPermissionsService: The service used to request permissions
    func requestLocationPermissions(using locationPermissionsService: LocationPermissionsService) {
        locationPermissionsService.requestPermissions { _ in
            // TODO patmcg handle issues on the location permissions request
        }
    }
    
    /// Zoom the map to a specific landmark
    /// - Parameter landmark: The landmark to zoom to
    func zoomTo(landmark: Landmark) {
        mapPosition = .camera(
            MapCamera(
                centerCoordinate: landmark.location,
                distance: 2000 // meters
            )
        )
    }
    
    /// Center the map on the user's current location
    func centerOnUserLocation() {
        mapPosition = .userLocation(fallback: .automatic)
        didTapLocate.toggle()
    }
    
    // MARK: - Private Methods
    
}
