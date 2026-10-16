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

    /// Launch argument used by `MapPlusUITests` to run against deterministic,
    /// in-memory data and mock services instead of the user's real data and
    /// live location/AI services.
    private static let isUITesting = ProcessInfo.processInfo.arguments.contains("UI-Testing")

    /// The main app starting point
    var body: some Scene {
        WindowGroup {
            rootView
        }
        .modelContainer(Self.makeModelContainer())
    }

    @ViewBuilder
    private var rootView: some View {
#if DEBUG
        if Self.isUITesting {
            MainMapView()
                .injectMockServices()
        } else {
            MainMapView()
                .modifier(InjectLiveServicesModifier())
        }
#else
        MainMapView()
            .modifier(InjectLiveServicesModifier())
#endif
    }

    @MainActor
    private static func makeModelContainer() -> ModelContainer {
#if DEBUG
        if isUITesting {
            return try! ModelContainer.inMemorySampleContainer()
        }
#endif
        return try! ModelContainer.persistentContainer()
    }
}
