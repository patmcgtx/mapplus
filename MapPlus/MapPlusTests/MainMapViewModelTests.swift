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
@Suite("MainMapViewModel Tests")
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
