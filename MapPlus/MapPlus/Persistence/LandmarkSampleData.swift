//
//  LandmarkSampleData.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 10/15/25.
//

import SwiftData
import SwiftUI
import MapKit

/// Some sample landmarks around Austin, TX i.e. for testing.
struct LandmarkSampleData {
    
    @State private var position: MapCameraPosition = .automatic
    
    /// A conerete, sample landmark for testing
    var capital: Landmark {
        Landmark(
            name: "Capital Lawn",
            notes: "Lawn of the Texas state capital building",
            formattedAddress: "1100 Congress Ave\nAustin, TX 78701",
            systemImageName: "building",
            location: CLLocationCoordinate2D(
                latitude: 30.27381,
                longitude: -97.74063
            )
        )
    }
    
    /// A few conerete, sample landmarks for testing
    var somePlaces: [Landmark] {
        [
            Landmark(
                name: "A place",
                notes: "Somewhere in Austin",
                formattedAddress: "123 Somewhere Ln\nAustin TX",
                systemImageName: "house",
                location: CLLocationCoordinate2D(
                    latitude: 30.22791,
                    longitude: -97.76270
                )
            ),
            Landmark(
                name: "Work",
                notes: "Another day, another dollar.",
                formattedAddress: "123 Work",
                systemImageName: "arcade.stick",
                location: CLLocationCoordinate2D(
                    latitude: 30.27267,
                    longitude: -97.74109
                )
            ),
            Landmark(
                name: "School",
                notes: "Learning and such",
                formattedAddress: "123 School",
                systemImageName: "graduationcap",
                location: CLLocationCoordinate2D(
                    latitude: 30.20632,
                    longitude: -97.77506
                )
            )
        ]
    }
    
    // TODO patmcg move this to its own file about ModelContainers
    @MainActor
    func inMemorySampleContainer() throws -> ModelContainer {
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Landmark.self, configurations: config)
        
        for landmark in self.somePlaces {
            container.mainContext.insert(landmark)
        }
        
        try container.mainContext.save()
        
        return container
    }
    
    // TODO patmcg move this to its own "real" / non-sample file
    @MainActor
    func persistentContainer() throws -> ModelContainer {
        let config = ModelConfiguration()
        let container = try! ModelContainer(for: Landmark.self, configurations: config)
        return container
    }
}
