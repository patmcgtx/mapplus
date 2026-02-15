//
//  LookAroundService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/15/26.
//

import MapKit

/// This service provides a map look-around view
protocol LookAroundService {

    func lookAroundScene(for location: CLLocationCoordinate2D) async throws -> MKLookAroundScene?

}
