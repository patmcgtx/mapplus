//
//  MainMapViewModelTests.swift
//  MapPlusTests
//
//  Created by Patrick McGonigle on 5/30/26.
//

import Testing
import MapKit
import CoreLocation
@testable import MapPlus

@MainActor
struct MainMapViewModelTests {
    
    // MARK: - Initial State Tests
    
    @Test("View model initializes with correct default state")
    func testInitialState() {
        let viewModel = MainMapViewModel()
        
        // UI State
        #expect(!viewModel.showingLandmarkList)
        #expect(!viewModel.isShowingAddLandmarkSheet)
        #expect(!viewModel.isShowingCategoryFilter)
        #expect(!viewModel.didTapLocate)
        
        // Map State
        #expect(viewModel.selectedLandmark == nil)
        
        // Animation State
        #expect(viewModel.glowingLandmarks.isEmpty)
        #expect(viewModel.fadingGlows.isEmpty)
        #expect(viewModel.glowScales.isEmpty)
        #expect(viewModel.glowOpacities.isEmpty)
        #expect(viewModel.animationTask == nil)
        
        // Preferences
        #expect(viewModel.activeTheme == .cupertino)
        #expect(viewModel.activePOILevel == .none)
    }
    
    @Test("Map position initializes to user location")
    func testInitialMapPosition() {
        let viewModel = MainMapViewModel()
        
        switch viewModel.mapPosition {
        case .userLocation(fallback: .automatic):
            break // Expected initial state
        default:
            Issue.record("Expected .userLocation(fallback: .automatic), got \(viewModel.mapPosition)")
        }
    }
    
    // MARK: - UI State Tests
    
    @Test("Showing landmark list can be toggled")
    func testShowingLandmarkList() {
        let viewModel = MainMapViewModel()
        
        #expect(!viewModel.showingLandmarkList)
        
        viewModel.showingLandmarkList = true
        #expect(viewModel.showingLandmarkList)
        
        viewModel.showingLandmarkList = false
        #expect(!viewModel.showingLandmarkList)
    }
    
    @Test("Showing add landmark sheet can be toggled")
    func testShowingAddLandmarkSheet() {
        let viewModel = MainMapViewModel()
        
        #expect(!viewModel.isShowingAddLandmarkSheet)
        
        viewModel.isShowingAddLandmarkSheet = true
        #expect(viewModel.isShowingAddLandmarkSheet)
        
        viewModel.isShowingAddLandmarkSheet = false
        #expect(!viewModel.isShowingAddLandmarkSheet)
    }
    
    @Test("Showing category filter can be toggled")
    func testShowingCategoryFilter() {
        let viewModel = MainMapViewModel()
        
        #expect(!viewModel.isShowingCategoryFilter)
        
        viewModel.isShowingCategoryFilter = true
        #expect(viewModel.isShowingCategoryFilter)
        
        viewModel.isShowingCategoryFilter = false
        #expect(!viewModel.isShowingCategoryFilter)
    }
    
    // MARK: - Map State Tests
    
    @Test("Selected landmark can be set and cleared")
    func testSelectedLandmark() {
        let viewModel = MainMapViewModel()
        let landmark = Landmark(name: "Test Place")
        
        #expect(viewModel.selectedLandmark == nil)
        
        viewModel.selectedLandmark = landmark
        #expect(viewModel.selectedLandmark === landmark)
        
        viewModel.selectedLandmark = nil
        #expect(viewModel.selectedLandmark == nil)
    }
    
    @Test("Zoom to landmark updates map position")
    func testZoomToLandmark() {
        let viewModel = MainMapViewModel()
        let landmark = Landmark(
            name: "Golden Gate Bridge",
            location: CLLocationCoordinate2D(latitude: 37.8199, longitude: -122.4783)
        )
        
        viewModel.zoomTo(landmark: landmark)
        
        // Extract the camera from the map position
        if let camera = viewModel.mapPosition.camera {
            #expect(camera.centerCoordinate.latitude == 37.8199)
            #expect(camera.centerCoordinate.longitude == -122.4783)
            #expect(camera.distance == 2000)
        } else {
            Issue.record("Expected map position to have a camera, got \(viewModel.mapPosition)")
        }
    }
    
    @Test("Center on user location updates map position and toggles didTapLocate")
    func testCenterOnUserLocation() {
        let viewModel = MainMapViewModel()
        
        #expect(!viewModel.didTapLocate)
        
        viewModel.centerOnUserLocation()
        
        // Verify it's set to user location with automatic fallback
        switch viewModel.mapPosition {
        case .userLocation(fallback: .automatic):
            break // Expected
        default:
            Issue.record("Expected .userLocation(fallback: .automatic), got \(viewModel.mapPosition)")
        }
        
        #expect(viewModel.didTapLocate)
        
        // Toggle again
        viewModel.centerOnUserLocation()
        #expect(!viewModel.didTapLocate)
    }
    
    // MARK: - Preferences Tests
    
    @Test("Active theme can be changed")
    func testActiveTheme() {
        let viewModel = MainMapViewModel()
        
        #expect(viewModel.activeTheme == .cupertino)
        
        viewModel.activeTheme = .eightBit
        #expect(viewModel.activeTheme == .eightBit)
        
        viewModel.activeTheme = .kerby
        #expect(viewModel.activeTheme == .kerby)
    }
    
    @Test("Active POI level can be changed")
    func testActivePOILevel() {
        let viewModel = MainMapViewModel()
        
        #expect(viewModel.activePOILevel == .none)
        
        viewModel.activePOILevel = .limited
        #expect(viewModel.activePOILevel == .limited)
        
        viewModel.activePOILevel = .all
        #expect(viewModel.activePOILevel == .all)
    }
    
    // MARK: - Animation Tests
    
    @Test("Animate landmark change with added landmarks applies glow")
    func testAnimateLandmarkChangeWithAddedLandmarks() async {
        let viewModel = MainMapViewModel()
        let landmark1 = Landmark(name: "Place 1")
        let landmark2 = Landmark(name: "Place 2")
        
        let previousLandmarks: [Landmark] = [landmark1]
        let newLandmarks: [Landmark] = [landmark1, landmark2]
        
        // Start the animation (don't await - we'll check intermediate state)
        let task = Task { @MainActor in
            await viewModel.animateLandmarkChange(from: previousLandmarks, to: newLandmarks)
        }
        
        // Give it a moment to apply the glow
        try? await Task.sleep(for: .milliseconds(100))
        
        // Verify the glow was applied to the new landmark
        #expect(viewModel.glowingLandmarks.contains(landmark2))
        #expect(!viewModel.glowingLandmarks.contains(landmark1))
        
        // Wait for completion
        await task.value
        
        // After animation completes, glow should be removed
        #expect(viewModel.glowingLandmarks.isEmpty)
    }
    
    @Test("Animate landmark change with removed landmarks creates fading glow")
    func testAnimateLandmarkChangeWithRemovedLandmarks() async {
        let viewModel = MainMapViewModel()
        let landmark1 = Landmark(name: "Place 1", location: CLLocationCoordinate2D(latitude: 37.0, longitude: -122.0))
        let landmark2 = Landmark(name: "Place 2", location: CLLocationCoordinate2D(latitude: 38.0, longitude: -123.0))
        
        let previousLandmarks: [Landmark] = [landmark1, landmark2]
        let newLandmarks: [Landmark] = [landmark1]
        
        // Start the animation
        let task = Task { @MainActor in
            await viewModel.animateLandmarkChange(from: previousLandmarks, to: newLandmarks)
        }
        
        // Give it a moment to create the fading glows
        try? await Task.sleep(for: .milliseconds(150))
        
        // Verify fading glows were created
        #expect(viewModel.fadingGlows.count == 1)
        #expect(viewModel.glowScales.count == 1)
        #expect(viewModel.glowOpacities.count == 1)
        
        // Initial scale and opacity should be 1.0
        let glowId = viewModel.fadingGlows.keys.first!
        #expect(viewModel.glowScales[glowId] != nil)
        #expect(viewModel.glowOpacities[glowId] != nil)
        
        // Wait for completion
        await task.value
        
        // After animation completes, fading glows should be cleared
        #expect(viewModel.fadingGlows.isEmpty)
        #expect(viewModel.glowScales.isEmpty)
        #expect(viewModel.glowOpacities.isEmpty)
    }
    
    @Test("Animate landmark change with no changes does nothing")
    func testAnimateLandmarkChangeWithNoChanges() async {
        let viewModel = MainMapViewModel()
        let landmark1 = Landmark(name: "Place 1")
        let landmark2 = Landmark(name: "Place 2")
        
        let landmarks: [Landmark] = [landmark1, landmark2]
        
        await viewModel.animateLandmarkChange(from: landmarks, to: landmarks)
        
        // No glows should be created
        #expect(viewModel.glowingLandmarks.isEmpty)
        #expect(viewModel.fadingGlows.isEmpty)
        #expect(viewModel.glowScales.isEmpty)
        #expect(viewModel.glowOpacities.isEmpty)
    }
    
    @Test("Animate landmark change with both added and removed landmarks")
    func testAnimateLandmarkChangeWithBothAddedAndRemoved() async {
        let viewModel = MainMapViewModel()
        let landmark1 = Landmark(name: "Place 1")
        let landmark2 = Landmark(name: "Place 2", location: CLLocationCoordinate2D(latitude: 37.0, longitude: -122.0))
        let landmark3 = Landmark(name: "Place 3")
        
        let previousLandmarks: [Landmark] = [landmark1, landmark2]
        let newLandmarks: [Landmark] = [landmark1, landmark3]
        
        // Start the animation
        let task = Task { @MainActor in
            await viewModel.animateLandmarkChange(from: previousLandmarks, to: newLandmarks)
        }
        
        // Give it a moment to process
        try? await Task.sleep(for: .milliseconds(100))
        
        // Both glow types should be active
        #expect(viewModel.glowingLandmarks.contains(landmark3)) // Added
        #expect(viewModel.fadingGlows.isEmpty) // Removed
        
        // Wait for completion
        await task.value
        
        // After completion, everything should be cleared
        #expect(viewModel.glowingLandmarks.isEmpty)
        #expect(viewModel.fadingGlows.isEmpty)
    }
    
    @Test("Animation task can be cancelled")
    func testAnimationTaskCancellation() async {
        let viewModel = MainMapViewModel()
        let landmark1 = Landmark(name: "Place 1")
        let landmark2 = Landmark(name: "Place 2")
        
        let previousLandmarks: [Landmark] = []
        let newLandmarks: [Landmark] = [landmark1, landmark2]
        
        // Start an animation
        viewModel.animationTask = Task { @MainActor in
            await viewModel.animateLandmarkChange(from: previousLandmarks, to: newLandmarks)
        }
        
        // Give it a moment to start
        try? await Task.sleep(for: .milliseconds(50))
        
        // Cancel it
        viewModel.animationTask?.cancel()
        
        // Wait a bit more
        try? await Task.sleep(for: .milliseconds(100))
        
        // The glowing landmarks should be cleared when task is cancelled
        #expect(viewModel.glowingLandmarks.isEmpty)
    }
    
    // MARK: - Location Permissions Tests
    
    @Test("Request location permissions calls service")
    func testRequestLocationPermissions() {
        let viewModel = MainMapViewModel()
        let mockService = MockLocationPermissionsService()
        
        #expect(!mockService.didRequestPermissions)
        
        viewModel.requestLocationPermissions(using: mockService)
        
        #expect(mockService.didRequestPermissions)
    }
    
}

// MARK: - Mock Location Permissions Service

/// Mock location permissions service for testing
final class MockLocationPermissionsService: LocationPermissionsService {
    var didRequestPermissions = false
    
    override func requestPermissions(callback: @escaping (CLAuthorizationStatus) -> Void) {
        didRequestPermissions = true
        callback(.authorizedWhenInUse)
    }
}
