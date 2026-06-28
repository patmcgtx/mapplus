//
//  Environment.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/14/26.
//

import SwiftUI
import FoundationModels

extension EnvironmentValues {
    
    // MARK: Service dependency injection
    //
    // For the main app, these services are injected by InjectServicesModifier.
    //
    // Why the !'s?
    //
    // Normally I don't love a !, but this would crash the app on launch every time
    // if a service isn't injected, which is preferable to silent failures and a lot
    // of ?'s all over the code with unreasonable error cases like basically,
    // "Sorry, this app can't operate because a service is missing." 🤦🏻‍♂️
    
    @Entry var locationService: LocationService!
    @Entry var locationPermissionService: LocationPermissionsService!
    @Entry var addressLookupService: LocationSearchService!
    @Entry var lookAroundService: LookAroundService!
    @Entry var categorySelectionService: CategorySelectionService!
    @Entry var mapItemSuggestionService: MapItemSuggestionService!
    @Entry var pointOfInterestService: PointOfInterestService!

    // MARK: Default settings
    
    @Entry var theme: MapPlusTheme = .cupertino
}

extension View {
    /// Injects live services into the environment.
    func injectLiveServices() -> some View {
        self.modifier(InjectLiveServicesModifier())
    }
}
    
/// View modifier that injects all live services into the environment.
struct InjectLiveServicesModifier: ViewModifier {
    
    @Environment(\.modelContext) private var modelContext
    
    func body(content: Content) -> some View {
        content
            .environment(\.locationService, MapKitLocationService())
            .environment(\.locationPermissionService, MapKitLocationPermissionsService())
            .environment(\.addressLookupService, MapKitLocationSearchService())
            .environment(\.lookAroundService, MapKitLookAroundService())
            .environment(\.categorySelectionService, CategorySelectionService(modelContext: modelContext))
            .environment(\.mapItemSuggestionService, mapItemSuggestionService)
            .environment(\.pointOfInterestService, MapKitPointOfInterestService())
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

#if DEBUG

/// View modifier that injects mock services into the environment.
struct InjectMockServicesModifier: ViewModifier {
    
    @Environment(\.modelContext) private var modelContext

    func body(content: Content) -> some View {
        content
            .environment(\.locationService, MockLocationService())
            .environment(\.locationPermissionService, AlwaysSucceedsLocationPermissionsService())
            .environment(\.addressLookupService, MockLocationSearchService())
            .environment(\.lookAroundService, MockLookAroundService())
            .environment(\.categorySelectionService, CategorySelectionService(modelContext: modelContext))
            .environment(\.mapItemSuggestionService, BasicMapItemSuggestionService())
            .environment(\.pointOfInterestService, MockPointOfInterestService())
    }
    
}

extension View {
    /// Injects mock services into the environment.
    func injectMockServices() -> some View {
        self.modifier(InjectMockServicesModifier())
    }
}

#endif // DEBUG
