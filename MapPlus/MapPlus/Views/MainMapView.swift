//
//  ContentView.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 9/6/25.
//

import SwiftUI
import SwiftData
import MapKit

/// The main map view, aka the "home" view.
struct MainMapView: View {
    
    // TODO patmcg rework this view with a view model?

    // Location
    private var locationPermissionsService = LocationPermissionsService()
    
    // UI state
    @State private var showingLandmarkList: Bool = false
    @State private var isShowingAddLandmarkSheet: Bool = false
    @State private var isShowingCategoryFilter: Bool = false
    @State private var didTapLocate: Bool = false

    // Map state
    @State private var mapPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedLandmark: Landmark?
    @State private var landmarkOpacities: [Landmark: Double] = [:]
    
    // Persistence
    @Environment(\.modelContext) private var modelContext

    // Landmarks
    @Query(sort: \Landmark.name, order: .reverse) var allLandmarks: [Landmark]
    
    @Query(filter: #Predicate<Landmark> { $0.categories.contains(where: { $0.isSelected }) })
    var filteredLandmarks: [Landmark]
    
    private var visibleLandmarks: [Landmark] {
        selectedCategories.isEmpty ? allLandmarks : filteredLandmarks
    }

    // Categories
    @Query var allCategories: [LandmarkCategory]
    
    @Query(filter: #Predicate<LandmarkCategory> { $0.isSelected })
    var selectedCategories: [LandmarkCategory]

    // Preferences
    @State private var activeTheme: MapPlusTheme = .cupertino
    @State private var activePOILevel: PointsOfInterestLevel = .none
        
    var body: some View {
        
        NavigationStack {
            ZStack {
                Map(position: $mapPosition, selection: self.$selectedLandmark) {
                    ForEach(visibleLandmarks, id: \.self) { landmark in
                        Annotation(landmark.name, coordinate: landmark.location, anchor: .bottom) {
                            LandmarkMapAnnotation(emoji: landmark.emoji)
                                .opacity(landmarkOpacities[landmark, default: 1.0])
                                .animation(.easeInOut(duration: 0.35), value: landmarkOpacities[landmark, default: 1.0])
                        }
                        .tag(landmark)
                    }
                    UserAnnotation()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("settings".localized, systemImage: "gearshape") {}
                        // TODO patmcg add settings form
                    }
                    ToolbarItem() {
                        themeMenu
                    }
                    ToolbarItem() {
                        poiMenu
                    }
                    ToolbarItem() {
                        categoriesButton
                            .popover(
                                isPresented: $isShowingCategoryFilter,
                                attachmentAnchor: .point(.topTrailing),
                                arrowEdge: .top
                            ) {
                                CategoriesSelectFlow()
                                    .padding()
                                    .frame(minWidth: 300, idealWidth: 400, maxWidth: .infinity)
                                    .presentationCompactAdaptation(.none)
                                    .presentationSizing(.fitted)
                            }
                    }
                }
                .sheet(item: self.$selectedLandmark) { landmark in
                    LandmarkDetailsView(landmark: landmark)
                        .presentationDetents([.medium, .large])
                }
                .mapStyle(MapStyle.standard(elevation: .realistic,
                                            emphasis: .muted,
                                            pointsOfInterest: activePOILevel.categories,
                                            showsTraffic: false))
                .mapControls {
                    MapCompass()
                    MapScaleView()
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 16) {
                            addButton
                            locateButton
                            landmarksMenu
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 16)
                    }
                }
            }
            .onAppear(){
                self.locationPermissionsService.requestPermissions() { _ in
                    // TODO patmcg handle issues on the location permissions request
                }
            }
            .onChange(of: visibleLandmarks) { _, _ in
                Task { @MainActor in
                    await animateLandmarkChange()
                }
            }
            .sheet(isPresented: $showingLandmarkList) {
                LandmarksView()
            }
            .sheet(isPresented: $isShowingAddLandmarkSheet) {
                NavigationStack {
                    LandmarkForm(mode: .create)
                }
            }
            .environment(\.theme, self.activeTheme)
            .apply(theme: activeTheme)
        }
    }
    
    // MARK: - Subviews
    
    var addButton: some View {
        DraggableControlButton(
            systemImageName: "plus",
            onTap: {
                isShowingAddLandmarkSheet = true
            },
            onMoved: { offset in
                // Persist button location here per ticket #179
            }
        )
        .accessibilityLabel("add-place".localized)
    }
        
    var locateButton: some View {
        DraggableControlButton(
            systemImageName: "location",
            onTap: {
                withAnimation {
                    self.mapPosition = .userLocation(fallback: .automatic)
                }
                didTapLocate.toggle()
            },
            onMoved: { offset in
                // Persist button location here per ticket #179
                print("Moved locate button by \(offset)")
            }
        )
        .accessibilityLabel("me".localized)
        .sensoryFeedback(.impact(weight: .light), trigger: didTapLocate)
    }
    
    var landmarksMenuDraggable : some View {
        DraggableControlButton(
            systemImageName: "list.bullet",
            onTap: {
                // TODO patmcg have to convert this to a "show menu" action and then use this instead of the old landmarksMenu
                self.showingLandmarkList = true
            },
            onMoved: { offset in
                // Persist button location here per ticket #179
            }
        )
        .accessibilityLabel("my-places-menu".localized)
    }

    // TODO patmcg this is an odd case - see landmarksMenuDraggable
    var landmarksMenu : some View {
        Menu {
            Button("my-places-menu".localized, systemImage: "list.bullet") {
                self.showingLandmarkList = true
            }
            Section {
                ForEach(self.allLandmarks, id: \.self) { landmark in
                    Button(action: {
                        zoomTo(landmark: landmark)
                    }, label: {
                        HStack {
                            Text(landmark.name)
                        }
                    })
                }
            }
        } label: {
            Image(systemName: "list.bullet")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.primary)
                .padding(16)
        }
        .accessibilityLabel("my-places-menu".localized)
        .glassEffect()
    }
    
    private var themeMenu: some View {
        Menu("theme".localized, systemImage: activeTheme.menuIconName) {
            Text("theme".localized)
            ForEach(MapPlusTheme.allCases) { themeOption in
                Button {
                    activeTheme = themeOption
                } label: {
                    HStack {
                        if themeOption == self.activeTheme {
                            Label(themeOption.localizedName, systemImage: "checkmark")
                        } else {
                            Text(themeOption.localizedName)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var poiMenu: some View {
        Menu("points-of-interest".localized, systemImage: activePOILevel.menuIconName) {
            Text("points-of-interest".localized)
            ForEach(PointsOfInterestLevel.allCases) { level in
                Button {
                    activePOILevel = level
                } label: {
                    HStack {
                        if level == activePOILevel {
                            Label(level.localizedName, systemImage: "checkmark")
                        } else {
                            Spacer()
                        }
                        Text(level.localizedName)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var categoriesButton: some View {
        // TODO patmcg move view logic ^ in here if you can
        let iconName = selectedCategories.isEmpty ? "map" : "map.fill"
        Button("categories".localized, systemImage: iconName) {
            isShowingCategoryFilter = true
        }
    }
    
    // MARK: - Helper Methods
    
    private func animateLandmarkChange() async { }

    /// Animate the selected landmarks changing
//    private func animateLandmarkChange() async {
//        let newLandmarks = filteredLandmarks
//        let currentSet = Set(displayedLandmarks)
//        let newSet = Set(newLandmarks)
//
//        // Determine which landmarks are being removed or added
//        let removed = displayedLandmarks.filter { !newSet.contains($0) }
//        let added = newLandmarks.filter { !currentSet.contains($0) }
//
//        // Fade out only the landmarks being removed
//        for landmark in removed {
//            landmarkOpacities[landmark] = 0.0
//        }
//
//        // Wait for fade out to complete (only if there are landmarks to remove)
//        if !removed.isEmpty {
//            try? await Task.sleep(for: .seconds(0.35))
//        }
//
//        // Start added landmarks at 0 opacity before inserting them
//        for landmark in added {
//            landmarkOpacities[landmark] = 0.0
//        }
//
//        // Update the displayed landmarks and clean up removed entries
//        displayedLandmarks = newLandmarks
//        for landmark in removed {
//            landmarkOpacities.removeValue(forKey: landmark)
//        }
//
//        // Small delay to ensure the update completes
//        try? await Task.sleep(for: .seconds(0.05))
//
//        // Fade in added landmarks
//        for landmark in added {
//            landmarkOpacities[landmark] = 1.0
//        }
//    }
    
    /// Returns landmarks filtered by the selected category names.
    /// If no categories are selected, all landmarks are returned.
//    private var filteredLandmarks: [Landmark] {
//        if selectedCategories.isEmpty {
//            return landmarks
//        }
//        return landmarks.filter { landmark in
//            landmark.categories.contains { $0.isSelected }
//        }
//    }

    private func zoomTo(landmark: Landmark) {
        withAnimation {
            self.mapPosition = .camera(
                MapCamera(
                    centerCoordinate: landmark.location,
                    distance: 2000 // meters
                )
            )
        }
    }

}

#if DEBUG

#Preview {
    MainMapView()
        .modelContainer(try! ModelContainer.inMemorySampleContainer())
}

#endif // DEBUG
