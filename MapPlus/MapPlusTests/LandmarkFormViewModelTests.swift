//
//  LandmarkFormViewModelTests.swift
//  MapPlusTests
//

import Testing
import MapKit
@testable import MapPlus

@MainActor
struct LandmarkFormViewModelTests {

    // MARK: - formTitle

    @Test func testFormTitleCreate() {
        let viewModel = LandmarkFormViewModel(mode: .create)
        #expect(viewModel.formTitle == "new-landmark".localized)
    }

    @Test func testFormTitleEdit() {
        let landmark = Landmark(name: "Golden Gate Bridge")
        let viewModel = LandmarkFormViewModel(mode: .edit(landmark))
        #expect(viewModel.formTitle == "Golden Gate Bridge")
    }

    // MARK: - isSaveEnabled

    @Test func testIsSaveEnabledInitially() {
        let viewModel = LandmarkFormViewModel(mode: .create)
        #expect(!viewModel.isSaveEnabled)
    }

    @Test func testIsSaveEnabledWhileSearching() {
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.addressSearchState = .searching
        #expect(!viewModel.isSaveEnabled)
    }

    @Test func testIsSaveEnabledAfterSearchFailed() {
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.addressSearchState = .searchFailed(MapPlusError.noAddressFound)
        #expect(!viewModel.isSaveEnabled)
    }

    @Test func testIsSaveEnabledAfterResolvedWithPopulatedName() {
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.landmarkToEdit.name = "My Place"
        viewModel.addressSearchState = .searchResolved(LocationInfo())
        #expect(viewModel.isSaveEnabled)
    }

    @Test func testIsSaveEnabledAfterResolvedWithEmptyName() {
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.landmarkToEdit.name = ""
        viewModel.addressSearchState = .searchResolved(LocationInfo())
        #expect(!viewModel.isSaveEnabled)
    }

    // MARK: - initializeLocation

    @Test func testInitializeLocationCreateSuccess() async {
        let viewModel = LandmarkFormViewModel(mode: .create)
        let mockService = MockLocationService()

        await viewModel.initializeLocation(using: mockService)

        if case .searchResolved(let info) = viewModel.addressSearchState {
            #expect(info.formattedDescription == "Current Location: San Francisco, CA, United States")
            #expect(viewModel.landmarkToEdit.formattedAddress == info.formattedDescription)
        } else {
            Issue.record("Expected .searchResolved, got \(viewModel.addressSearchState)")
        }
    }

    @Test func testInitializeLocationCreateFailureStaysAtInitial() async {
        let viewModel = LandmarkFormViewModel(mode: .create)
        let mockService = MockLocationService()
        mockService.shouldSucceed = false

        await viewModel.initializeLocation(using: mockService)

        // Location failure on create is silent; state stays at searchInitial
        if case .searchInitial = viewModel.addressSearchState {
            // Expected
        } else {
            Issue.record("Expected .searchInitial, got \(viewModel.addressSearchState)")
        }
    }

    @Test func testInitializeLocationEditPrePopulatesExistingAddress() async {
        let landmark = Landmark(
            name: "Test",
            formattedAddress: "123 Main St",
            location: .init(latitude: 37.77, longitude: -122.41)
        )
        let viewModel = LandmarkFormViewModel(mode: .edit(landmark))
        let mockService = MockLocationService()

        await viewModel.initializeLocation(using: mockService)

        if case .searchResolved(let info) = viewModel.addressSearchState {
            #expect(info.formattedDescription == "123 Main St")
            #expect(info.coordinates.latitude == 37.77)
            #expect(info.coordinates.longitude == -122.41)
        } else {
            Issue.record("Expected .searchResolved, got \(viewModel.addressSearchState)")
        }
    }

    // MARK: - searchByText

    @Test func testSearchByTextSuccess() async {
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.locationSearchInput = "San Francisco"
        let mockService = MockAddressLookupService()

        await viewModel.searchByText(using: mockService)

        if case .searchResolved(let info) = viewModel.addressSearchState {
            #expect(info.formattedDescription == "San Francisco, CA, United States")
            #expect(viewModel.locationSearchInput == "San Francisco, CA, United States")
            #expect(viewModel.landmarkToEdit.formattedAddress == "San Francisco, CA, United States")
        } else {
            Issue.record("Expected .searchResolved, got \(viewModel.addressSearchState)")
        }
    }

    @Test func testSearchByTextFailure() async {
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.locationSearchInput = "Nowhere"
        let mockService = MockAddressLookupService(shouldSucceed: false)

        await viewModel.searchByText(using: mockService)

        if case .searchFailed = viewModel.addressSearchState {
            // Expected
        } else {
            Issue.record("Expected .searchFailed, got \(viewModel.addressSearchState)")
        }
    }

    // MARK: - searchByCurrentLocation

    @Test func testSearchByCurrentLocationSuccess() async {
        let viewModel = LandmarkFormViewModel(mode: .create)
        let mockService = MockLocationService()

        await viewModel.searchByCurrentLocation(using: mockService)

        if case .searchResolved(let info) = viewModel.addressSearchState {
            #expect(info.formattedDescription == "Current Location: San Francisco, CA, United States")
            #expect(viewModel.locationSearchInput == "Current Location: San Francisco, CA, United States")
            #expect(viewModel.landmarkToEdit.formattedAddress == info.formattedDescription)
        } else {
            Issue.record("Expected .searchResolved, got \(viewModel.addressSearchState)")
        }
    }

    @Test func testSearchByCurrentLocationFailure() async {
        let viewModel = LandmarkFormViewModel(mode: .create)
        let mockService = MockLocationService()
        mockService.shouldSucceed = false

        await viewModel.searchByCurrentLocation(using: mockService)

        if case .searchFailed = viewModel.addressSearchState {
            // Expected
        } else {
            Issue.record("Expected .searchFailed, got \(viewModel.addressSearchState)")
        }
    }

}
