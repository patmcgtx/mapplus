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
                        Button("Edit...", systemImage: "list.number") {
                            // TODO Open landmarks edit screen
                        }
                        Divider()
                        ForEach(self.landmarks, id: \.self) { landmark in
                            Button(landmark.name, systemImage: landmark.systemImageName) {
                                zoomTo(landmark: landmark)
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
                            .background(Color.white.opacity(0.5))
                            .padding(.trailing, 16)
                    }
                }
            }
        }
        .onAppear(){
            self.locationHandler.requestPermissions() { _ in  }
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
    ContentView()
        .modelContainer(try! LandmarkSampleData().inMemoryContainer())
}
