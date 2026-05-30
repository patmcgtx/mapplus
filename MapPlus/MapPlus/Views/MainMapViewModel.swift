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
    
    // MARK: - Animation State
    
    /// Landmarks that should show a glow effect
    var glowingLandmarks: Set<Landmark> = []
    
    /// Fading glow animations for removed landmarks
    var fadingGlows: [UUID: CLLocationCoordinate2D] = [:]
    
    /// Scale values for fading glow animations
    var glowScales: [UUID: CGFloat] = [:]
    
    /// Opacity values for fading glow animations
    var glowOpacities: [UUID: Double] = [:]
    
    /// Active animation task (for cancellation)
    var animationTask: Task<Void, Never>?
    
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
    
    /// Animate the transition when visible landmarks change
    /// - Parameters:
    ///   - previousLandmarks: The landmarks visible before the change
    ///   - newLandmarks: The landmarks visible after the change
    func animateLandmarkChange(
        from previousLandmarks: [Landmark],
        to newLandmarks: [Landmark]
    ) async {
        // Thanks to Claude for iterating with me on this animation logic...
        
        let addedLandmarks = Set(newLandmarks).subtracting(Set(previousLandmarks))
        let removedLandmarks = Set(previousLandmarks).subtracting(Set(newLandmarks))
        
        // Add glow to newly added landmarks
        if !addedLandmarks.isEmpty {
            await MainActor.run {
                glowingLandmarks = Set(addedLandmarks)
            }
            
            // Remove glow after 0.5 seconds
            do {
                try await Task.sleep(for: .seconds(0.5))
            } catch {
                await MainActor.run { glowingLandmarks = [] }
                return
            }
            
            await MainActor.run {
                glowingLandmarks = []
            }
        }
        
        // Add fading glows for removed landmarks
        if !removedLandmarks.isEmpty {
            let glowsToAdd = removedLandmarks.map { (UUID(), $0.location) }
            
            await MainActor.run {
                for (id, coordinate) in glowsToAdd {
                    fadingGlows[id] = coordinate
                    glowScales[id] = 1.0
                    glowOpacities[id] = 1.0
                }
            }
            
            // Small delay to let SwiftUI render the initial state
            do {
                try await Task.sleep(for: .milliseconds(100))
            } catch {
                await MainActor.run { clearFadingGlowState() }
                return
            }
            
            // Animate the "poof" effect - expand and fade out like smoke
            let animationDuration = 0.5
            await MainActor.run {
                withAnimation(.easeOut(duration: animationDuration)) {
                    for (id, _) in glowsToAdd {
                        glowScales[id] = 2.5
                        glowOpacities[id] = 0.0
                    }
                }
            }
            
            // wait for the animation to complete before cleaning up
            do {
                try await Task.sleep(for: .seconds(animationDuration))
            } catch {
                await MainActor.run { clearFadingGlowState() }
                return
            }
            
            // Clear all glow dictionaries after animation completes
            await MainActor.run {
                clearFadingGlowState()
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Clear all fading glow state
    private func clearFadingGlowState() {
        fadingGlows.removeAll()
        glowScales.removeAll()
        glowOpacities.removeAll()
    }
}
