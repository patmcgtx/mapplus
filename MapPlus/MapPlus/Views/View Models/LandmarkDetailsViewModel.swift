//
//  LandmarkDetailsViewModel.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 6/30/26.
//

import MapKit

/// View model that provides Look Around state and loading logic for `LandmarkDetailsView`.
@Observable @MainActor
final class LandmarkDetailsViewModel {

    // MARK: Data types

    enum LookAroundState {
        case initial
        case loading
        case resolved(MKLookAroundScene)
        case notAvailable
        case failure(Error)
    }

    // MARK: View config properties

    let landmark: Landmark

    // MARK: UI state

    var lookAroundState: LookAroundState = .initial

    // MARK: Initialization

    init(landmark: Landmark) {
        self.landmark = landmark
    }

    // MARK: Actions

    func loadLookAround(using lookAroundService: LookAroundService) async {
        lookAroundState = .loading

        do {
            if let scene = try await lookAroundService.lookAroundScene(for: landmark.location) {
                lookAroundState = .resolved(scene)
            } else {
                lookAroundState = .notAvailable
            }
        } catch {
            lookAroundState = .failure(error)
        }
    }
}
