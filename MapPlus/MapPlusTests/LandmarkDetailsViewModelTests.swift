//
//  LandmarkDetailsViewModelTests.swift
//  MapPlusTests
//
//  Created by Patrick McGonigle on 6/30/26.
//

import CoreLocation
import MapKit
import Testing
@testable import MapPlus

@MainActor
@Suite("LandmarkDetailsViewModel Tests")
struct LandmarkDetailsViewModelTests {

    // MARK: - Helpers

    private enum TestError: Error, Equatable {
        case lookAroundFailed
    }

    private final class StubLookAroundService: LookAroundService {
        let delay: Duration
        let sceneToReturn: MKLookAroundScene?
        let errorToThrow: Error?
        private(set) var receivedLocations: [CLLocationCoordinate2D] = []

        init(
            delay: Duration = .zero,
            sceneToReturn: MKLookAroundScene? = nil,
            errorToThrow: Error? = nil
        ) {
            self.delay = delay
            self.sceneToReturn = sceneToReturn
            self.errorToThrow = errorToThrow
        }

        func lookAroundScene(for location: CLLocationCoordinate2D) async throws -> MKLookAroundScene? {
            receivedLocations.append(location)

            if delay > .zero {
                try? await Task.sleep(for: delay)
            }

            if let errorToThrow {
                throw errorToThrow
            }

            return sceneToReturn
        }
    }

    private func makeViewModel() -> LandmarkDetailsViewModel {
        LandmarkDetailsViewModel(
            landmark: Landmark(
                name: "Brooklyn Bridge",
                location: CLLocationCoordinate2D(latitude: 40.7061, longitude: -73.9969)
            )
        )
    }

    private func isLoading(_ state: LandmarkDetailsViewModel.LookAroundState) -> Bool {
        if case .loading = state {
            return true
        }

        return false
    }

    private func isNotAvailable(_ state: LandmarkDetailsViewModel.LookAroundState) -> Bool {
        if case .notAvailable = state {
            return true
        }

        return false
    }

    // MARK: - Tests

    @Test("Loading Look Around enters loading state before completing")
    func loadLookAroundSetsLoadingState() async {
        let viewModel = makeViewModel()
        let service = StubLookAroundService(delay: .milliseconds(50))

        let task = Task {
            await viewModel.loadLookAround(using: service)
        }

        await Task.yield()

        #expect(isLoading(viewModel.lookAroundState))

        await task.value

        #expect(isNotAvailable(viewModel.lookAroundState))
        #expect(service.receivedLocations.count == 1)
        #expect(service.receivedLocations[0].latitude == 40.7061)
        #expect(service.receivedLocations[0].longitude == -73.9969)
    }

    @Test("Loading Look Around stores failure state when the service throws")
    func loadLookAroundFailure() async {
        let viewModel = makeViewModel()
        let service = StubLookAroundService(errorToThrow: TestError.lookAroundFailed)

        await viewModel.loadLookAround(using: service)

        switch viewModel.lookAroundState {
        case .failure(let error as TestError):
            #expect(error == .lookAroundFailed)
        default:
            Issue.record("Expected a failure state when Look Around loading throws")
        }
    }
}
