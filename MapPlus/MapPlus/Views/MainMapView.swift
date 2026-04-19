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
    
    // TODO patmcg rework this view with a proper view model

    // Location
    private var locationPermissionsService = LocationPermissionsService()
    
    // UI state
    @State private var showingLandmarkList: Bool = false
    @State private var isShowingAddLandmarkSheet: Bool = false
    @State private var isShowingCategoryFilter: Bool = false

    // Map state
    @State private var mapPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedLandmark: Landmark?
    @State private var displayedLandmarks: [Landmark] = []
    @State private var animationOpacity: Double = 1.0
    
    // Persistence
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Landmark.name, order: .reverse) var landmarks: [Landmark]

    // Categories
    @State private var allCategories: [LandmarkCategory] = []

    // Preferences
    @State private var activeTheme: MapPlusTheme = .cupertino
    @State private var activePOILevel: PointsOfInterestLevel = .none
        
    var body: some View {
        
        NavigationStack {
            ZStack {
                Map(position: $mapPosition, selection: self.$selectedLandmark) {
                    ForEach(displayedLandmarks, id: \.self) { landmark in
                        Annotation(landmark.name, coordinate: landmark.location, anchor: .bottom) {
                            LandmarkMapAnnotation(emoji: landmark.emoji)
                                .opacity(animationOpacity)
                                .animation(.easeInOut(duration: 0.35), value: animationOpacity)
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
                                CategoriesSelectFlow(allCategories: $allCategories)
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
            .task {
                loadCategories(from: modelContext)
                displayedLandmarks = filteredLandmarks
            }
            .onChange(of: selectedCategories) { _, _ in
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
            },
            onMoved: { offset in
                // Persist button location here per ticket #179
                print("Moved locate button by \(offset)")
            }
        )
        .accessibilityLabel("me".localized)
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
                ForEach(self.landmarks, id: \.self) { landmark in
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
        Button("Categories", systemImage: iconName) {
            isShowingCategoryFilter = true
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadCategories(from context: ModelContext) {
        let descriptor = FetchDescriptor<LandmarkCategory>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        allCategories = (try? context.fetch(descriptor)) ?? []
    }
    
    private var selectedCategories: Set<LandmarkCategory> {
        Set(allCategories.filter({ $0.isSelected }))
    }

    /// Animate the selected landmarks changing
    private func animateLandmarkChange() async {
        // Fade out current landmarks
        animationOpacity = 0.0
        
        // Wait for fade out to complete
        try? await Task.sleep(for: .seconds(0.35))
        
        // Update the landmarks while invisible
        displayedLandmarks = filteredLandmarks
        
        // Small delay to ensure the update completes
        try? await Task.sleep(for: .seconds(0.05))
        
        // Fade in new landmarks
        animationOpacity = 1.0
    }
    
    /// Returns landmarks filtered by the selected category names.
    /// If no categories are selected, all landmarks are returned.
    private var filteredLandmarks: [Landmark] {
        if selectedCategories.isEmpty {
            return landmarks
        }
        return landmarks.filter { landmark in
            landmark.categories.contains { $0.isSelected }
        }
    }

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
