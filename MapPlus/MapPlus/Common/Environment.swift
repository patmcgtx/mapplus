//
//  Environment.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/14/26.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var locationService: LocationService = MockLocationService()
    @Entry var addressLookupService: AddressLookupService = MockAddressLookupService()
}
