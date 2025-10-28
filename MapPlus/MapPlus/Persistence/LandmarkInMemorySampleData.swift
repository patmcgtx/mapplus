//
//  LandmarkSampleData.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 10/15/25.
//

import SwiftData
import SwiftUI
import MapKit

struct LandmarkInMemorySampleData {
    
    @State private var position: MapCameraPosition = .automatic

    @MainActor
    static var container: ModelContainer {
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Landmark.self, configurations: config)

        // Populate sample data
        
        let home = CLLocationCoordinate2D(latitude: 30.22791, longitude: -97.76270)
        let work = CLLocationCoordinate2D(latitude: 30.27267, longitude: -97.74109)
        let school = CLLocationCoordinate2D(latitude: 30.20632, longitude: -97.77506)
        
        container.mainContext.insert(
            Landmark(name: "Home", systemImageName: "house", location: home))
        
        container.mainContext.insert(
            Landmark(name: "Mom's work", systemImageName: "arcade.stick", location: work))

        container.mainContext.insert(
            Landmark(name: "School", systemImageName: "graduationcap", location: school))

        return container
    }
}
