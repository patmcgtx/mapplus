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

    // Map state
    @State private var mapPosition: MapCameraPosition = .automatic
    @State private var mapSelectedItem: MKMapItem?
    
    // Persistence
    @Query var landmarks: [Landmark]

    var body: some View {
        
        Map(position: $mapPosition, selection: $mapSelectedItem) {
            ForEach(landmarks, id: \.self) { landmark in
                Marker(landmark.name, systemImage: landmark.systemImageName, coordinate: landmark.location)
            }
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
        .safeAreaInset(edge: .bottom, alignment: .trailing) {
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
                    // TODO Zoom to my location
                }
            } label: {
                Image(systemName: "mappin.circle")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .padding(.trailing, 16)
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

#Preview {
    ContentView()
        .modelContainer(LandmarkInMemorySampleData().container)
}
