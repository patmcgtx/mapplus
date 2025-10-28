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
                    Button("Home") { self.focusOnLandmark(named: "Home") }
                    Spacer()
                    Button("School") { self.focusOnLandmark(named: "School") }
                    Spacer()
                    Button("Mom's work") { self.focusOnLandmark(named: "Mom's work") }
                    Spacer()
                    Button("Edit") {}
                }
            }
            .labelStyle(.titleAndIcon)
            .padding(.top)
            .background(.ultraThinMaterial)
        }
    }
    
    private func focusOnLandmark(named landmarkName: String) {
        if let focus = landmarks.filter({ $0.name == landmarkName }).first?.location {
            withAnimation {
                self.mapPosition = .camera(
                    MapCamera(
                        centerCoordinate: focus,
                        distance: 2000
                    )
                )
            }
        }
    }

}

#Preview {
    ContentView()
        .modelContainer(LandmarkInMemorySampleData.container)
}
