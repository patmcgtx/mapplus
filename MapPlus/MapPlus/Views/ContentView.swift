//
//  ContentView.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 9/6/25.
//

import SwiftUI
import SwiftData
import MapKit

/// The main map view
struct ContentView: View {

    // Location
    private var locationHandler = LocationHandler()
    
    // Landamrks editing
    @State private var showingLandmarkList: Bool = false
    
    // Map state
    @State private var mapPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var mapSelectedItem: MKMapItem?
    
    // Persistence
    @Query var landmarks: [Landmark]

    var body: some View {
        
        ZStack {
            Map(position: $mapPosition, selection: $mapSelectedItem) {
                ForEach(landmarks, id: \.self) { landmark in
                    Marker(
                        landmark.name,
                        systemImage: landmark.systemImageName,
                        coordinate: landmark.location
                    )
                }
                UserAnnotation()
            } // Map
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
            } // mapStyle

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
                    } // Menu
                }
            } // VStack
        } // ZStack
        .onAppear(){
            self.locationHandler.requestPermissions() { _ in  }
        }
        .sheet(isPresented: $showingLandmarkList) {
            LandmarksView(landmarks: self.landmarks)
        }
    } // body
    
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
    ContentView()
        .modelContainer(try! LandmarkSampleData().inMemorySampleContainer())
}
