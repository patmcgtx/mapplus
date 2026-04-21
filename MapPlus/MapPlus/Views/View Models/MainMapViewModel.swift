//
//  MainMapViewModel.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 4/21/26.
//

import SwiftUI
import SwiftData
import MapKit

/// View model that provides state and logic for `MainMapView`.
@Observable @MainActor
final class MainMapViewModel {

    // MARK: - Private

    /// Service used to request device location permissions (not exposed to the view).
    private let locationPermissionsService = LocationPermissionsService()

    // MARK: - UI State

    /// Whether the landmark list sheet is being shown.
    var showingLandmarkList: Bool = false

    /// Whether the add-landmark sheet is being shown.
    var isShowingAddLandmarkSheet: Bool = false

    /// Whether the category-filter popover is being shown.
    var isShowingCategoryFilter: Bool = false

    // MARK: - Map State

    /// The current camera position on the map.
    var mapPosition: MapCameraPosition = .userLocation(fallback: .automatic)

    /// The landmark currently selected on the map, if any.
    var selectedLandmark: Landmark?

    /// The landmarks currently rendered on the map (may differ from the full list during animations).
    var displayedLandmarks: [Landmark] = []

    /// Per-landmark opacity values used for fade-in / fade-out animations.
    var landmarkOpacities: [Landmark: Double] = [:]

    // MARK: - Categories & Preferences

    /// All available landmark categories loaded from persistence.
    var allCategories: [LandmarkCategory] = []

    /// The active map theme.
    var activeTheme: MapPlusTheme = .cupertino

    /// The active points-of-interest display level.
    var activePOILevel: PointsOfInterestLevel = .none

    // MARK: - Computed Properties

    /// The set of categories that have been selected by the user.
    var selectedCategories: Set<LandmarkCategory> {
        Set(allCategories.filter { $0.isSelected })
    }

    /// The system image name to use for the categories toolbar button.
    ///
    /// Returns `"map.fill"` when at least one category is selected, otherwise `"map"`.
    var categoriesIconName: String {
        selectedCategories.isEmpty ? "map" : "map.fill"
    }

    // MARK: - Methods

    /// Requests "when in use" location permissions from the system.
    func requestLocationPermissions() {
        locationPermissionsService.requestPermissions() { _ in
            // TODO patmcg handle issues on the location permissions request
        }
    }

    /// Sets up initial state by loading categories and seeding displayed landmarks.
    ///
    /// Call this once from the view's `.task` modifier.
    /// - Parameters:
    ///   - context: The SwiftData model context to fetch categories from.
    ///   - landmarks: The full list of landmarks to derive the initial displayed set from.
    func setup(modelContext context: ModelContext, landmarks: [Landmark]) {
        loadCategories(from: context)
        displayedLandmarks = filteredLandmarks(from: landmarks)
    }

    /// Loads available categories from persistence and stores them in `allCategories`.
    /// - Parameter context: The SwiftData model context to fetch categories from.
    func loadCategories(from context: ModelContext) {
        let descriptor = FetchDescriptor<LandmarkCategory>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        allCategories = (try? context.fetch(descriptor)) ?? []
    }

    /// Returns the subset of `landmarks` that match the currently selected categories.
    ///
    /// If no categories are selected, all landmarks are returned.
    /// - Parameter landmarks: The full list of landmarks to filter.
    /// - Returns: The filtered array of landmarks.
    func filteredLandmarks(from landmarks: [Landmark]) -> [Landmark] {
        if selectedCategories.isEmpty {
            return landmarks
        }
        return landmarks.filter { landmark in
            landmark.categories.contains { $0.isSelected }
        }
    }

    /// Animates the transition between the currently displayed landmarks and the new filtered set.
    ///
    /// Landmarks that are being removed fade out first; landmarks that are being added fade in
    /// after the removal animation completes.
    /// - Parameter landmarks: The full list of landmarks to derive the new display set from.
    func animateLandmarkChange(landmarks: [Landmark]) async {
        let newLandmarks = filteredLandmarks(from: landmarks)
        let currentSet = Set(displayedLandmarks)
        let newSet = Set(newLandmarks)

        // Determine which landmarks are being removed or added
        let removed = displayedLandmarks.filter { !newSet.contains($0) }
        let added = newLandmarks.filter { !currentSet.contains($0) }

        // Fade out only the landmarks being removed
        for landmark in removed {
            landmarkOpacities[landmark] = 0.0
        }

        // Wait for fade out to complete (only if there are landmarks to remove)
        if !removed.isEmpty {
            try? await Task.sleep(for: .seconds(0.35))
        }

        // Start added landmarks at 0 opacity before inserting them
        for landmark in added {
            landmarkOpacities[landmark] = 0.0
        }

        // Update the displayed landmarks and clean up removed entries
        displayedLandmarks = newLandmarks
        for landmark in removed {
            landmarkOpacities.removeValue(forKey: landmark)
        }

        // Small delay to ensure the update completes
        try? await Task.sleep(for: .seconds(0.05))

        // Fade in added landmarks
        for landmark in added {
            landmarkOpacities[landmark] = 1.0
        }
    }

    /// Zooms the map to centre on the given landmark.
    /// - Parameter landmark: The landmark to zoom to.
    func zoomTo(landmark: Landmark) {
        withAnimation {
            mapPosition = .camera(
                MapCamera(
                    centerCoordinate: landmark.location,
                    distance: 2000 // meters
                )
            )
        }
    }

    /// Zooms the map back to the user's current location.
    func zoomToUserLocation() {
        withAnimation {
            mapPosition = .userLocation(fallback: .automatic)
        }
    }
}
