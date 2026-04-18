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

    // Location
    private var locationPermissionsService = LocationPermissionsService()
    
    // UI state
    @State private var showingLandmarkList: Bool = false
    @State private var isShowingAddLandmarkSheet: Bool = false
    @State private var isShowingCategoryFilter: Bool = false

    // Map state
    @State private var mapPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedLandmark: Landmark?
    @State private var showMarkers: Bool = true
    
    // Filter state
    @State private var selectedCategoryNames: Set<String> = []

    // Persistence
    @Query(sort: \Landmark.name, order: .reverse) var landmarks: [Landmark]
    
    // TODO patmcg good grief, why is this here, AI?  Should be in a model or view model, right?
    // TODO patmcg didn't this get moved to the view model?
    @Query(sort: \LandmarkCategory.name, order: .forward) var allCategories: [LandmarkCategory]

    // Preferences
    @State private var activeTheme: MapPlusTheme = .cupertino
    @State private var activePOILevel: PointsOfInterestLevel = .none
        
    var body: some View {
        
        NavigationStack {
            ZStack {
                Map(position: $mapPosition, selection: self.$selectedLandmark) {
                    if showMarkers {
                        ForEach(filteredLandmarks, id: \.self) { landmark in
                            Annotation(landmark.name, coordinate: landmark.location, anchor: .bottom) {
                                LandmarkMapAnnotation(emoji: landmark.emoji)
                            }
                            .tag(landmark)
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
                                CategoriesSelectFlow(categories: .constant(allCategories))
                                .padding()
                                .frame(width: UIScreen.main.bounds.width * 0.85) // TODO patmcg adjust, using modern method
                                .presentationCompactAdaptation(.none)
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
            .task(id: selectedCategoryNames) {
                await blinkLandmarks()
            }
            .sheet(isPresented: $showingLandmarkList) {
                LandmarksView()
            }
            .sheet(isPresented: $isShowingAddLandmarkSheet) {
                NavigationStack {
                    LandmarkForm(mode: .create)
                }
            }
//            .sheet(isPresented: $isShowingCategoryFilter) {
//                CategoryFilterView(
//                    allCategories: allCategories,
//                    selectedCategoryNames: $selectedCategoryNames
//                )
//                .presentationDetents([.medium, .large])
//            }
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
    
    // TODO patmcg remove this
    @ViewBuilder
    var filterButtonOld: some View {
        let imageName = selectedCategoryNames.isEmpty
        ? "line.3.horizontal.decrease.circle"
        : "line.3.horizontal.decrease.circle.fill"
        DraggableControlButton(
            systemImageName: imageName,
            onTap: {
                isShowingCategoryFilter = true
            },
            onMoved: { offset in
                // Persist button location here per ticket #179
            }
        )
        .accessibilityLabel("filter-by-category".localized)
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
//                            Text(landmark.emoji) // TODO patmcg some bug here...
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
    
    @ViewBuilder var categoriesButton: some View {
        // theatermasks, map, circle.grid.3x3, mappin.and.ellipse.circle.fill, square.stack.3d.down.right.fill, circle.grid.2x2.topleft.checkmark.filled
        let iconName = allCategories.isEmpty ? "circle.grid.3x3.fill" : "map"
        Button("Categories", systemImage: iconName) {
            isShowingCategoryFilter = true
        }
    }
    
    @ViewBuilder
    private var categoriesMenuOld: some View {
        Menu("Categories".localized, systemImage: "camera.filters") {
            Text("Categories")
            Button {
                selectedCategoryNames = []
            } label: {
                HStack {
                    if selectedCategoryNames.isEmpty {
                        Label("All", systemImage: "checkmark")
                    } else {
                        Spacer()
                    }
                    Text("All")
                }
            }
            Divider()
            ForEach(allCategories) { category in
                Button {
                    if selectedCategoryNames.contains(category.name) {
                        selectedCategoryNames.remove(category.name)
                    } else {
                        selectedCategoryNames.insert(category.name)
                    }
                } label: {
                    HStack {
                        Spacer()
                        if selectedCategoryNames.contains(category.name) {
                            Label(category.name, systemImage: "checkmark")
                        }
                        Text(category.name)
                    }
                }
            }
            Divider()
            Button {
                // TODO patmcg add category edit screen
            } label: {
                Text("Edit...")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Animate the selected landmarks changing
    private func blinkLandmarks() async {
        let animateSecs = 0.25
        do {
            await MainActor.run {
                withAnimation(.easeOut(duration: animateSecs)) {
                    showMarkers = false
                }
            }
            try await Task.sleep(for: .seconds(animateSecs))
            await MainActor.run {
                withAnimation(.easeOut(duration: animateSecs)) {
                    showMarkers = true
                }
            }
        } catch {
            await MainActor.run { showMarkers = true }
        }
    }
    
    /// Returns landmarks filtered by the selected category names.
    /// If no categories are selected, all landmarks are returned.
    private var filteredLandmarks: [Landmark] {
        if selectedCategoryNames.isEmpty {
            return landmarks
        }
        return landmarks.filter { landmark in
            landmark.categories.contains { selectedCategoryNames.contains($0.name) }
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
