//
//  MainMapView.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 9/6/25.
//

import SwiftUI
import SwiftData
import MapKit

/// The main map view, aka the "home" view.
struct MainMapView: View {
        
    // MARK: Environment
    
    @Environment(\.locationPermissionService)
    private var locationPermissionsService: LocationPermissionsService

    @Environment(\.categorySelectionService)
    private var categoriesService: CategorySelectionService

    // MARK: App storage
    
    @AppStorage(AppStorageKeys.theme.rawValue)
    private var theme: MapPlusTheme = .cupertino
    
    @AppStorage(AppStorageKeys.poiLevel.rawValue)
    private var poiLevel: PointsOfInterestLevel = .none

    // MARK: Persistence
    
    @Query(sort: \Landmark.name, order: .reverse)
    var allLandmarks: [Landmark]
    
    // MARK: View state
    
    @State
    private var viewModel = MainMapViewModel()

    // MARK: Animation State
    
    /// Landmarks that should show a glow effect
    @State
    private var glowingLandmarks: Set<Landmark> = []
    
    /// Fading glow animations for removed landmarks
    @State
    private var fadingGlows: [UUID: CLLocationCoordinate2D] = [:]
    
    /// Scale values for fading glow animations
    @State
    private var glowScales: [UUID: CGFloat] = [:]
    
    /// Opacity values for fading glow animations
    @State
    private var glowOpacities: [UUID: Double] = [:]
    
    /// Active animation task (for cancellation)
    @State
    private var animationTask: Task<Void, Never>?
        
    // MARK: - Views
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                Map(position: $viewModel.mapPosition, selection: $viewModel.selectedLandmark) {
                    ForEach(visibleLandmarks, id: \.self) { landmark in
                        Annotation(landmark.name, coordinate: landmark.location, anchor: .bottom) {
                            LandmarkMapAnnotation(symbol: landmark.symbol)
                                .shadow(
                                    color: glowingLandmarks.contains(landmark) ? theme.tintColor : .clear,
                                    radius: glowingLandmarks.contains(landmark) ? 12 : 0
                                )
                                .shadow(
                                    color: glowingLandmarks.contains(landmark) ? theme.tintColor.opacity(0.6) : .clear,
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
                                    .fill(theme.tintColor.opacity(0.3))
                                    .frame(width: 20, height: 20)
                                    .shadow(color: theme.tintColor.opacity(0.5), radius: 8)
                                    .shadow(color: theme.tintColor.opacity(0.3), radius: 12)
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
                        // Will implement this button for #178, #179, #299
                        Button("settings".localized, systemImage: "gearshape") {}
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
                                isPresented: $viewModel.isShowingCategoryFilter,
                                attachmentAnchor: .point(.topTrailing),
                                arrowEdge: .top
                            ) {
                                CategoriesSelectFlow()
                                    .padding()
                                // Have to specify a concrete width or idealWidth for the view
                                // to show up on-screen due to the HFlow inside the CategoriesSelectFlow.
                                // Basically putting an HFlow inside a popover seems to have some issues.
                                    .frame(minWidth: 300, idealWidth: 400, maxWidth: .infinity)
                                    .presentationCompactAdaptation(.popover)
                            }
                    }
                }
                .sheet(item: $viewModel.selectedLandmark) { landmark in
                    LandmarkDetailsView(landmark: landmark)
                        .presentationDetents([.medium, .large])
                }
                .mapStyle(MapStyle.standard(elevation: .realistic,
                                            emphasis: .muted,
                                            pointsOfInterest: poiLevel.categories,
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
                viewModel.requestLocationPermissions(using: locationPermissionsService)
            }
            .onChange(of: visibleLandmarks) { oldVisibleLandmarks, newVisibleLandmarks in
                animationTask?.cancel()
                animationTask = Task { @MainActor in
                    await animateLandmarkChange(from: oldVisibleLandmarks, to: newVisibleLandmarks)
                }
            }
            .onDisappear {
                animationTask?.cancel()
            }
            .sheet(isPresented: $viewModel.showingLandmarkList) {
                LandmarksView()
            }
            .sheet(isPresented: $viewModel.isShowingAddLandmarkSheet) {
                NavigationStack {
                    LandmarkForm(mode: .create)
                }
            }
            .apply(theme: theme)
        }
    }
    
    var addButton: some View {
        DraggableControlButton(
            systemImageName: "plus",
            onTap: {
                viewModel.isShowingAddLandmarkSheet = true
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
                    viewModel.centerOnUserLocation()
                }
            },
            onMoved: { offset in
                // Persist button location here per ticket #179
                print("Moved locate button by \(offset)")
            }
        )
        .accessibilityLabel("me".localized)
        .sensoryFeedback(.impact(weight: .light), trigger: viewModel.didTapLocate)
    }
    
    var landmarksMenuDraggable : some View {
        DraggableControlButton(
            systemImageName: "list.bullet",
            onTap: {
                // Will use this view in issue #158
                viewModel.showingLandmarkList = true
            },
            onMoved: { offset in
                // Persist button location here per ticket #179
            }
        )
        .accessibilityLabel("my-places-menu".localized)
        .sensoryFeedback(.impact(weight: .light), trigger: viewModel.didTapLocate)
    }

    // Will switch this view to `landmarksMenuDraggable` in issue #158
    var landmarksMenu : some View {
        Menu {
            Button("my-places-menu".localized, systemImage: "list.bullet") {
                viewModel.showingLandmarkList = true
            }
            Section {
                ForEach(self.allLandmarks, id: \.self) { landmark in
                    Button(action: {
                        withAnimation {
                            viewModel.zoomTo(landmark: landmark)
                        }
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
        Menu("theme".localized, systemImage: theme.menuIconName) {
            Text("theme".localized)
            ForEach(MapPlusTheme.allCases) { themeOption in
                Button {
                    theme = themeOption
                } label: {
                    HStack {
                        if themeOption == theme {
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
        Menu("points-of-interest".localized, systemImage: poiLevel.menuIconName) {
            Text("points-of-interest".localized)
            ForEach(PointsOfInterestLevel.allCases) { level in
                Button {
                    poiLevel = level
                } label: {
                    HStack {
                        if level == poiLevel {
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
        let iconName = categoriesService.hasSelectedCategories ? "map.fill" : "map"
        Button("categories".localized, systemImage: iconName) {
            viewModel.isShowingCategoryFilter = true
        }
    }
    
    // MARK: Private helpers
    
    private var visibleLandmarks: [Landmark] {
        categoriesService.filterLandmarks(allLandmarks)
    }

    // MARK: Animation

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

    @MainActor
    private func clearFadingGlowState() {
        fadingGlows.removeAll()
        glowScales.removeAll()
        glowOpacities.removeAll()
    }
    
}

#if DEBUG

#Preview("Real") {
    MainMapView()
        .injectLiveServices()
}

#endif // DEBUG
