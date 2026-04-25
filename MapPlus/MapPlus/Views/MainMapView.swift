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
    @State private var glowingLandmarks: Set<Landmark> = []
    @State private var fadingGlows: [UUID: CLLocationCoordinate2D] = [:]
    @State private var glowScales: [UUID: CGFloat] = [:]
    @State private var glowOpacities: [UUID: Double] = [:]
    @State private var animationTask: Task<Void, Never>?
    
    // Persistence
    @Environment(\.modelContext) private var modelContext

    // Landmarks
    @Query(sort: \Landmark.name, order: .reverse) var allLandmarks: [Landmark]
    
    @Query(filter: #Predicate<Landmark> { $0.categories.contains(where: { $0.isSelected }) },
           sort: \Landmark.name)
    var filteredLandmarks: [Landmark]
    
    private var visibleLandmarks: [Landmark] {
        selectedCategories.isEmpty ? allLandmarks : filteredLandmarks
    }

    // Categories
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
                                .shadow(
                                    color: glowingLandmarks.contains(landmark) ? activeTheme.tintColor : .clear,
                                    radius: glowingLandmarks.contains(landmark) ? 12 : 0
                                )
                                .shadow(
                                    color: glowingLandmarks.contains(landmark) ? activeTheme.tintColor.opacity(0.6) : .clear,
                                    radius: glowingLandmarks.contains(landmark) ? 20 : 0
                                )
                                .animation(.easeOut(duration: 0.3), value: glowingLandmarks)
                        }
                        .tag(landmark)
                    }
                    
                    // Fading glows for removed landmarks
                    ForEach(Array(fadingGlows.keys), id: \.self) { glowId in
                        if let coordinate = fadingGlows[glowId] {
                            Annotation("", coordinate: coordinate) {
                                Circle()
                                    .fill(activeTheme.tintColor.opacity(0.3))
                                    .frame(width: 20, height: 20)
                                    .shadow(color: activeTheme.tintColor.opacity(0.5), radius: 8)
                                    .shadow(color: activeTheme.tintColor.opacity(0.3), radius: 12)
                                    .scaleEffect(glowScales[glowId] ?? 1.0)
                                    .opacity(glowOpacities[glowId] ?? 1.0)
                                    .animation(.easeOut(duration: 0.5), value: glowScales[glowId])
                                    .animation(.easeOut(duration: 0.5), value: glowOpacities[glowId])
                            }
                        }
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
            .onChange(of: visibleLandmarks) { oldVisibleLandmarks, newVisibleLandmarks in
                animationTask?.cancel()
                animationTask = Task { @MainActor in
                    await animateLandmarkChange(from: oldVisibleLandmarks, to: newVisibleLandmarks)
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
    
    /// Animate the selected landmarks changing
    private func animateLandmarkChange(
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
                await MainActor.run {
                    fadingGlows.removeAll()
                    glowScales.removeAll()
                    glowOpacities.removeAll()
                }
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
                await MainActor.run {
                    fadingGlows.removeAll()
                    glowScales.removeAll()
                    glowOpacities.removeAll()
                }
                return
            }
            
            // Clear all glow dictionaries after animation completes
            await MainActor.run {
                fadingGlows.removeAll()
                glowScales.removeAll()
                glowOpacities.removeAll()
            }
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
