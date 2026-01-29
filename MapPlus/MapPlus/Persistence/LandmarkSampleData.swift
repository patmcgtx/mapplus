//
//  LandmarkSampleData.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 10/15/25.
//

import SwiftData
import SwiftUI
import MapKit

struct LandmarkSampleData {
    
    @State private var position: MapCameraPosition = .automatic
    
    var sampleData: [Landmark] {
        [
            Landmark(
                name: "Home",
                systemImageName: "house",
                location: CLLocationCoordinate2D(
                    latitude: 30.22791,
                    longitude: -97.76270
                )
            ),
            Landmark(
                name: "Mom's work",
                systemImageName: "arcade.stick",
                location: CLLocationCoordinate2D(
                    latitude: 30.27267,
                    longitude: -97.74109
                )
            ),
            Landmark(
                name: "School",
                systemImageName: "graduationcap",
                location: CLLocationCoordinate2D(
                    latitude: 30.20632,
                    longitude: -97.77506
                )
            )
        ]
    }
    
    @MainActor
    func inMemorySampleContainer() throws -> ModelContainer {
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Landmark.self, configurations: config)
        
        for landmark in self.sampleData {
            container.mainContext.insert(landmark)
        }
        
        try container.mainContext.save()
        
        return container
    }
    
    @MainActor
    func persistentContainer() throws -> ModelContainer {
        let config = ModelConfiguration()
        let container = try! ModelContainer(for: Landmark.self, configurations: config)
        return container
    }
}
