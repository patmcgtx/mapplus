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
    
    // View model manages all state and business logic
    @State private var viewModel = MainMapViewModel()
    
    // Location service
    private var locationPermissionsService = LocationPermissionsService()
    
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
        
    var body: some View {
        
        NavigationStack {
            ZStack {
                Map(position: $viewModel.mapPosition, selection: $viewModel.selectedLandmark) {
                    ForEach(visibleLandmarks, id: \.self) { landmark in
                        Annotation(landmark.name, coordinate: landmark.location, anchor: .bottom) {
                            LandmarkMapAnnotation(emoji: landmark.emoji)
                                .shadow(
                                    color: viewModel.glowingLandmarks.contains(landmark) ? viewModel.activeTheme.tintColor : .clear,
                                    radius: viewModel.glowingLandmarks.contains(landmark) ? 12 : 0
                                )
                                .shadow(
                                    color: viewModel.glowingLandmarks.contains(landmark) ? viewModel.activeTheme.tintColor.opacity(0.6) : .clear,
                                    radius: viewModel.glowingLandmarks.contains(landmark) ? 20 : 0
                                )
                                .animation(.easeOut(duration: 0.3), value: viewModel.glowingLandmarks)
                        }
                        .tag(landmark)
                    }
                    
                    // Fading glows for removed landmarks
                    ForEach(Array(viewModel.fadingGlows.keys), id: \.self) { glowId in
                        if let coordinate = viewModel.fadingGlows[glowId] {
                            Annotation("", coordinate: coordinate) {
                                Circle()
                                    .fill(viewModel.activeTheme.tintColor.opacity(0.3))
                                    .frame(width: 20, height: 20)
                                    .shadow(color: viewModel.activeTheme.tintColor.opacity(0.5), radius: 8)
                                    .shadow(color: viewModel.activeTheme.tintColor.opacity(0.3), radius: 12)
                                    .scaleEffect(viewModel.glowScales[glowId] ?? 1.0)
                                    .opacity(viewModel.glowOpacities[glowId] ?? 1.0)
                                    .animation(.easeOut(duration: 0.5), value: viewModel.glowScales[glowId])
                                    .animation(.easeOut(duration: 0.5), value: viewModel.glowOpacities[glowId])
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
                                            pointsOfInterest: viewModel.activePOILevel.categories,
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
                viewModel.animationTask?.cancel()
                viewModel.animationTask = Task { @MainActor in
                    await viewModel.animateLandmarkChange(from: oldVisibleLandmarks, to: newVisibleLandmarks)
                }
            }
            .sheet(isPresented: $viewModel.showingLandmarkList) {
                LandmarksView()
            }
            .sheet(isPresented: $viewModel.isShowingAddLandmarkSheet) {
                NavigationStack {
                    LandmarkForm(mode: .create)
                }
            }
            .environment(\.theme, viewModel.activeTheme)
            .apply(theme: viewModel.activeTheme)
        }
    }
    
    // MARK: - Subviews
    
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
                // TODO patmcg have to convert this to a "show menu" action and then use this instead of the old landmarksMenu
                viewModel.showingLandmarkList = true
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
        Menu("theme".localized, systemImage: viewModel.activeTheme.menuIconName) {
            Text("theme".localized)
            ForEach(MapPlusTheme.allCases) { themeOption in
                Button {
                    viewModel.activeTheme = themeOption
                } label: {
                    HStack {
                        if themeOption == viewModel.activeTheme {
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
        Menu("points-of-interest".localized, systemImage: viewModel.activePOILevel.menuIconName) {
            Text("points-of-interest".localized)
            ForEach(PointsOfInterestLevel.allCases) { level in
                Button {
                    viewModel.activePOILevel = level
                } label: {
                    HStack {
                        if level == viewModel.activePOILevel {
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
            viewModel.isShowingCategoryFilter = true
        }
    }
    
    // MARK: - Helper Methods
    
    // Animation logic is now in the view model
    
}

#if DEBUG

#Preview {
    MainMapView()
        .modelContainer(try! ModelContainer.inMemorySampleContainer())
}

#endif // DEBUG
