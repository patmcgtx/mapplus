//
//  MapPlusApp.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 9/6/25.
//

import SwiftUI
import SwiftData
import FoundationModels

@main
struct MapPlusApp: App {

    /// The main app starting point
    var body: some Scene {
        WindowGroup {
            MainMapView()
                .modifier(InjectLiveServicesModifier())
        }
        .modelContainer(try! ModelContainer.persistentContainer())
    }
}
