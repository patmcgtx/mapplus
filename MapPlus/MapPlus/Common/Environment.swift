//
//  Environment.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/14/26.
//

import SwiftUI

extension EnvironmentValues {
    
    // Let's go with the real services by default; if I want to mock
    // up some scenarios for previews and tests, do it there.
    
    @Entry var locationService: LocationService = MapKitLocationService()
    @Entry var addressLookupService: AddressLookupService = MapKitAddressLookupService()
    @Entry var lookAroundService: LookAroundService = MapKitLookAroundService()
    @Entry var theme: MapPlusTheme = .basic
}
