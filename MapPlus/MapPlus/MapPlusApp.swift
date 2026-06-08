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

    var body: some Scene {
        WindowGroup {
            MainMapView()
                .modifier(InjectServicesModifier())
        }
        .modelContainer(try! ModelContainer.persistentContainer())
    }
}

/// View modifier that injects all services into the environment.
/// This must be applied after modelContainer is set up so that services
/// requiring modelContext can access it.
private struct InjectServicesModifier: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    
    func body(content: Content) -> some View {
        content
            .environment(\.locationService, MapKitLocationService())
            .environment(\.addressLookupService, MapKitAddressLookupService())
            .environment(\.lookAroundService, MapKitLookAroundService())
            .environment(\.categorySelectionService, DefaultCategorySelectionService(modelContext: modelContext))
            .environment(\.mapItemSuggestionService, mapItemSuggestionService)
    }
    
    /// Returns the appropriate MapItemSuggestionService based on device capabilities
    private var mapItemSuggestionService: MapItemSuggestionService {
        // Check if Apple Intelligence / Foundation Models are available
        if SystemLanguageModel.default.availability == .available {
            return AIMapItemSuggestionService()
        } else {
            return BasicMapItemSuggestionService()
        }
    }
}
