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
    private var locationPermissionsService = LocationPermissonsService()
    
    // UI state
    @State private var showingLandmarkList: Bool = false
    
    // Map state
    @State private var mapPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedLandmark: Landmark?
    
    // Persistence
    @Query(sort: \Landmark.name, order: .reverse) var landmarks: [Landmark]

    var body: some View {
        
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
//                    .presentationDetents([.fraction(0.33), .medium])
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
                    Menu {
                        Button("My Places...", systemImage: "list.number") {
                            self.showingLandmarkList = true
                        }
                        Divider()
                        ForEach(self.landmarks, id: \.self) { landmark in
                            Button(landmark.name, systemImage: landmark.systemImageName) {
                                self.zoomTo(landmark: landmark)
                            }
                        }
                        Button("Me", systemImage: "location") {
                            withAnimation {
                                self.mapPosition = .userLocation(fallback: .automatic)
                            }
                        }
                    } label: {
                        Image(systemName: "mappin.circle")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .padding(.trailing, 16)
                    }
                }
            }
        }
        .onAppear(){
            self.locationPermissionsService.requestPermissions() { _ in
                // TODO patmcg handle issues on the location permissions request
            }
        }
        .sheet(isPresented: $showingLandmarkList) {
            LandmarksView()
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
