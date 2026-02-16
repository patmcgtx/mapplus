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
    
    // Map state
    @State private var mapPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedLandmark: Landmark?
    
    // Button position state - persisted across app launches
    @AppStorage("menuButtonX") private var menuButtonX: Double = 0
    @AppStorage("menuButtonY") private var menuButtonY: Double = 0
    @State private var buttonOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    
    // Persistence
    @Query(sort: \Landmark.name, order: .reverse) var landmarks: [Landmark]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Map(position: $mapPosition, selection: self.$selectedLandmark) {
                    ForEach(landmarks, id: \.self) { landmark in
                        Marker(
                            landmark.name,
                            systemImage: landmark.systemImageName,
                            coordinate: landmark.location
                        )
                        .tag(landmark)
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

                // Draggable menu button with liquid glass effect
                Menu {
                    Button("my-places-menu".localized, systemImage: "list.bullet") {
                        self.showingLandmarkList = true
                    }
                    Divider()
                    ForEach(self.landmarks, id: \.self) { landmark in
                        Button(landmark.name, systemImage: landmark.systemImageName) {
                            self.zoomTo(landmark: landmark)
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
                .position(
                    x: menuButtonX == 0 ? geometry.size.width - 44 : menuButtonX + buttonOffset.width,
                    y: menuButtonY == 0 ? geometry.size.height - 44 : menuButtonY + buttonOffset.height
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            self.isDragging = true
                            self.buttonOffset = value.translation
                        }
                        .onEnded { value in
                            self.isDragging = false
                            
                            // Calculate new position
                            let buttonSize: CGFloat = 56 // 24 + 16 padding on each side
                            var newX = (menuButtonX == 0 ? geometry.size.width - 44 : menuButtonX) + value.translation.width
                            var newY = (menuButtonY == 0 ? geometry.size.height - 44 : menuButtonY) + value.translation.height
                            
                            // Constrain to screen bounds
                            newX = max(buttonSize / 2, min(geometry.size.width - buttonSize / 2, newX))
                            newY = max(buttonSize / 2, min(geometry.size.height - buttonSize / 2, newY))
                            
                            // Update stored position
                            withAnimation(.spring()) {
                                self.menuButtonX = newX
                                self.menuButtonY = newY
                                self.buttonOffset = .zero
                            }
                        }
                )
                .scaleEffect(isDragging ? 1.1 : 1.0)
                .animation(.spring(response: 0.3), value: isDragging)
                
                // "Me" button - fixed position in bottom-right corner
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
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
                        .padding(.trailing, 16)
                        .padding(.bottom, 16)
                    }
                }
            }
            .onAppear(){
                self.locationPermissionsService.requestPermissions() { _ in
                    // TODO patmcg handle issues on the location permissions request
                }
                
                // Initialize default position if not set
                if menuButtonX == 0 && menuButtonY == 0 {
                    self.menuButtonX = geometry.size.width - 44
                    self.menuButtonY = geometry.size.height - 44
                }
            }
            .sheet(isPresented: $showingLandmarkList) {
                LandmarksView()
            }
        }
    }
    
    // MARK: - Helper Methods
    
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
