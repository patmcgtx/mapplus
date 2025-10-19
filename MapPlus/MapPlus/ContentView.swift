//
//  ContentView.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 9/6/25.
//

import SwiftUI
import SwiftData
import MapKit

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
        .mapControls{
            MapUserLocationButton()
            MapCompass()
        }
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
                    Button("Show All", systemImage: "location") {
                    }
                    Spacer()
                    Button("Show All", systemImage: "location") {
                    }
                    Spacer()
                    Button("Show All", systemImage: "location") {
                    }
                }
            }
            .labelStyle(.titleAndIcon)
            .padding(.top)
            .background(.ultraThinMaterial)
        }
    }

}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView()
        .modelContainer(LandmarkInMemorySampleData.container)
}
