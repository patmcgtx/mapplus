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

    // Persistence
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Landmark.name, order: .reverse) var landmarks: [Landmark]

    // View model owns all state and logic
    @State private var viewModel = MainMapViewModel()
        
    var body: some View {
        
        NavigationStack {
            ZStack {
                Map(position: $viewModel.mapPosition, selection: $viewModel.selectedLandmark) {
                    ForEach(viewModel.displayedLandmarks, id: \.self) { landmark in
                        Annotation(landmark.name, coordinate: landmark.location, anchor: .bottom) {
                            LandmarkMapAnnotation(emoji: landmark.emoji)
                                .opacity(viewModel.landmarkOpacities[landmark, default: 1.0])
                                .animation(.easeInOut(duration: 0.35), value: viewModel.landmarkOpacities[landmark, default: 1.0])
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
                                isPresented: $viewModel.isShowingCategoryFilter,
                                attachmentAnchor: .point(.topTrailing),
                                arrowEdge: .top
                            ) {
                                CategoriesSelectFlow(allCategories: $viewModel.allCategories)
                                    .padding()
                                    .frame(minWidth: 300, idealWidth: 400, maxWidth: .infinity)
                                    .presentationCompactAdaptation(.none)
                                    .presentationSizing(.fitted)
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
                viewModel.requestLocationPermissions()
            }
            .task {
                viewModel.setup(modelContext: modelContext, landmarks: landmarks)
            }
            .onChange(of: landmarks) { _, _ in
                Task { @MainActor in
                    await viewModel.animateLandmarkChange(landmarks: landmarks)
                }
            }
            .onChange(of: viewModel.selectedCategories) { _, _ in
                Task { @MainActor in
                    await viewModel.animateLandmarkChange(landmarks: landmarks)
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
                viewModel.zoomToUserLocation()
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
                ForEach(self.landmarks, id: \.self) { landmark in
                    Button(action: {
                        viewModel.zoomTo(landmark: landmark)
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
        Button("categories".localized, systemImage: viewModel.categoriesIconName) {
            viewModel.isShowingCategoryFilter = true
        }
    }

}

#if DEBUG

#Preview {
    MainMapView()
        .modelContainer(try! ModelContainer.inMemorySampleContainer())
}

#endif // DEBUG
