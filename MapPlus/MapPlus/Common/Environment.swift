//
//  Environment.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/14/26.
//

import SwiftUI

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
    @Entry var locationPermissionsService: LocationPermissionsServicing!
    @Entry var addressLookupService: AddressLookupService!
    @Entry var lookAroundService: LookAroundService!
    @Entry var categorySelectionService: CategorySelectionService!
    @Entry var mapItemSuggestionService: MapItemSuggestionService!

    // MARK: Default settings
    
    @Entry var theme: MapPlusTheme = .cupertino
}
