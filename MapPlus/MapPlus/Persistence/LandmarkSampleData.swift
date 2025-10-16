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
    
    @MainActor
    static var container: ModelContainer {
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Landmark.self, configurations: config)

        // Populate sample data
        
        let capitol = CLLocationCoordinate2D(latitude: 30.27267, longitude: -97.74109)
        let sagebrush = CLLocationCoordinate2D(latitude: 30.20632, longitude: -97.77506)
        let domain = CLLocationCoordinate2D(latitude: 30.40041, longitude: -97.72298)
        
        container.mainContext.insert(
            Landmark(name: "Capitol", systemImageName: "building", location: capitol))
        
        container.mainContext.insert(
            Landmark(name: "Sagebrush", systemImageName: "building", location: sagebrush))

        container.mainContext.insert(
            Landmark(name: "Domain", systemImageName: "building", location: domain))

        return container
    }
}
