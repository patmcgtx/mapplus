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
    @Query(sort: \LandmarkCategory.name, order: .forward) var allCategories: [LandmarkCategory]

    // Themes
    @State private var activeTheme: MapPlusTheme = .standard
    
    var body: some View {
        
        ZStack {
            Map(position: $mapPosition, selection: self.$selectedLandmark) {
                if showMarkers {
                    ForEach(filteredLandmarks, id: \.self) { landmark in
                        Marker(
                            landmark.name,
                            systemImage: landmark.systemImageName,
                            coordinate: landmark.location
                        )
                        .tag(landmark)
                    }
                }
                UserAnnotation()
            }
            .sheet(item: self.$selectedLandmark) { landmark in
                LandmarkDetailsView(landmark: landmark)
                    .presentationDetents([.medium, .large])
            }
            .mapStyle(MapStyle.standard(elevation: .realistic,
                                        emphasis: .muted,
                                        pointsOfInterest: [
                                            .library,
                                            .school,
                                            .fireStation,
                                            .hospital,
                                            .pharmacy,
                                            .police
                                        ],
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
                        filterButton
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
        .onChange(of: selectedCategoryNames) {
            Task {
                await blinkLandmarks()
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
        .sheet(isPresented: $isShowingCategoryFilter) {
            CategoryFilterView(
                allCategories: allCategories,
                selectedCategoryNames: $selectedCategoryNames
            )
            .presentationDetents([.medium, .large])
        }
        .environment(\.theme, self.activeTheme)
        .apply(theme: activeTheme)
    }
    
    // MARK: - Subviews
    
    var addButton: some View {
        Button(action: {
            isShowingAddLandmarkSheet = true
        }) {
            Image(systemName: "plus")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.primary)
                .padding(16)
        }
        .glassEffect()
    }
    
    var filterButton: some View {
        Button(action: {
            isShowingCategoryFilter = true
        }) {
            // TODO patmcg there is a lot of biz logic around selectedCategoryNames
            //      -> refactor to a view model
            Image(systemName: selectedCategoryNames.isEmpty
                  ? "line.3.horizontal.decrease.circle"
                  : "line.3.horizontal.decrease.circle.fill")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.primary)
                .padding(16)
        }
        .accessibilityLabel("filter-by-category".localized)
        .glassEffect()
    }
    
    var locateButton: some View {
        Button(action: {
            withAnimation {
                self.mapPosition = .userLocation(fallback: .automatic)
            }
        }) {
            Image(systemName: "location")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.primary)
                .padding(16)
        }
        .accessibilityLabel("me".localized)
        .glassEffect()
    }
    
    var landmarksMenu : some View {
        Menu {
            Button("my-places-menu".localized, systemImage: "list.bullet") {
                self.showingLandmarkList = true
            }
            themeMenu
            Section {
                ForEach(self.landmarks, id: \.self) { landmark in
                    Button(landmark.name, systemImage: landmark.systemImageName) {
                        self.zoomTo(landmark: landmark)
                    }
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
        Menu("theme".localized, systemImage: "paintbrush") {
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

#Preview {
    MainMapView()
        .modelContainer(try! ModelContainer.inMemorySampleContainer())
}
