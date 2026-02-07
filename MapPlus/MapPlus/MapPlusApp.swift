//
//  MapPlusApp.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 9/6/25.
//

import SwiftUI
import SwiftData

@main
struct MapPlusApp: App {

    var body: some Scene {
        WindowGroup {
            MainMapView()
        }
        .modelContainer(try! ModelContainer.persistentContainer())
    }
}
