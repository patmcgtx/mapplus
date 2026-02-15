//
//  Environment.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/14/26.
//

import SwiftUI

extension EnvironmentValues {
    // TODO patmcg user the real services by default
    @Entry var locationService: LocationService = MockLocationService()
    @Entry var addressLookupService: AddressLookupService = MockAddressLookupService()
    @Entry var lookAroundService: LookAroundService = MockLookAroundService(
        errorToThrow: nil,
        sceneToReturn: nil,
        networkDelaySeconds: 1.5
    )
}
