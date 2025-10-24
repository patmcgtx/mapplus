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
        .safeAreaInset(edge: .bottom) {
            ScrollView(.horizontal) {
                HStack {
                    Spacer()
                    Button("Refresh", systemImage: "location") {
                    }
                    Spacer()
                    Button("Clear", systemImage: "location") {
                    }
                    Spacer()
                    Button("Show 1", systemImage: "location") {
                    }
                    Spacer()
                    Button("Show 2", systemImage: "location") {
                    }
                    Spacer()
                    Button("Show 3", systemImage: "location") {
                    }
                }
            }
            .mapControls{
                MapCompass()
            }
            .labelStyle(.titleAndIcon)
            .padding(.top)
            .background(.ultraThinMaterial)
        }
    }

}

#Preview {
    ContentView()
        .modelContainer(LandmarkInMemorySampleData.container)
}
