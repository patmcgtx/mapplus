//
//  LandmarkFormViewModelTests.swift
//  MapPlusTests
//

import Testing
import MapKit
import SwiftData
@testable import MapPlus

@MainActor
struct LandmarkFormViewModelTests {

    // MARK: - Initial state

    @Test func testInitialAddressSearchState() {
        let viewModel = LandmarkFormViewModel(mode: .create)
        if case .searchInitial = viewModel.addressSearchState {
            // Expected
        } else {
            Issue.record("Expected .searchInitial, got \(viewModel.addressSearchState)")
        }
    }

    @Test func testInitialSaveState() {
        let viewModel = LandmarkFormViewModel(mode: .create)
        #expect(viewModel.saveState == .saveInitial)
    }

    @Test func testInitialLocationSearchInput() {
        let viewModel = LandmarkFormViewModel(mode: .create)
        #expect(viewModel.locationSearchInput == "")
    }

    @Test func testInitialLandmarkToEditIsEmptyForCreate() {
        let viewModel = LandmarkFormViewModel(mode: .create)
        #expect(viewModel.landmarkToEdit.name == "")
        #expect(viewModel.landmarkToEdit.formattedAddress == "")
    }

    @Test func testInitialLandmarkToEditIsProvidedLandmarkForEdit() {
        let landmark = Landmark(name: "Statue of Liberty", formattedAddress: "New York, NY")
        let viewModel = LandmarkFormViewModel(mode: .edit(landmark))
        #expect(viewModel.landmarkToEdit === landmark)
    }

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

    @Test func testIsSaveEnabledAfterResolvedWithWhitespaceOnlyName() {
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.landmarkToEdit.name = "   "
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

    @Test func testInitializeLocationCreateSuccessDoesNotUpdateLocationSearchInput() async {
        let viewModel = LandmarkFormViewModel(mode: .create)
        let mockService = MockLocationService()

        await viewModel.initializeLocation(using: mockService)

        #expect(viewModel.locationSearchInput == "")
    }

    @Test func testInitializeLocationCreateSuccessUpdatesCoordinates() async {
        let viewModel = LandmarkFormViewModel(mode: .create)
        let mockService = MockLocationService()

        await viewModel.initializeLocation(using: mockService)

        #expect(viewModel.landmarkToEdit.latitude == 37.7749)
        #expect(viewModel.landmarkToEdit.longitude == -122.4194)
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

    @Test func testSearchByTextSuccessUpdatesCoordinates() async {
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.locationSearchInput = "San Francisco"
        let mockService = MockAddressLookupService()

        await viewModel.searchByText(using: mockService)

        #expect(viewModel.landmarkToEdit.latitude == 37.7749)
        #expect(viewModel.landmarkToEdit.longitude == -122.4194)
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

    @Test func testSearchByCurrentLocationSuccessUpdatesCoordinates() async {
        let viewModel = LandmarkFormViewModel(mode: .create)
        let mockService = MockLocationService()

        await viewModel.searchByCurrentLocation(using: mockService)

        #expect(viewModel.landmarkToEdit.latitude == 37.7749)
        #expect(viewModel.landmarkToEdit.longitude == -122.4194)
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

    // MARK: - save

    @Test func testSaveSuccessSetsSaveStateToSaved() throws {
        let container = try ModelContainer(
            for: Landmark.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.landmarkToEdit.name = "New Place"
        viewModel.landmarkToEdit.latitude = 37.77
        viewModel.landmarkToEdit.longitude = -122.41

        viewModel.save(context: container.mainContext)

        #expect(viewModel.saveState == .saved)
    }

    @Test func testSaveSuccessInsertsLandmarkInContext() throws {
        let container = try ModelContainer(
            for: Landmark.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.landmarkToEdit.name = "Persisted Place"
        viewModel.landmarkToEdit.latitude = 40.71
        viewModel.landmarkToEdit.longitude = -74.00

        viewModel.save(context: container.mainContext)

        let stored = try container.mainContext.fetch(FetchDescriptor<Landmark>())
        #expect(stored.count == 1)
        #expect(stored.first?.name == "Persisted Place")
    }

    @Test func testSaveInEditModeUpdatesSaveState() throws {
        let container = try ModelContainer(
            for: Landmark.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let landmark = Landmark(name: "Old Name", location: .init(latitude: 51.50, longitude: -0.12))
        container.mainContext.insert(landmark)
        try container.mainContext.save()

        let viewModel = LandmarkFormViewModel(mode: .edit(landmark))
        viewModel.landmarkToEdit.name = "New Name"

        viewModel.save(context: container.mainContext)

        #expect(viewModel.saveState == .saved)
        let stored = try container.mainContext.fetch(FetchDescriptor<Landmark>())
        #expect(stored.first?.name == "New Name")
    }

    @Test func testSaveFailureSetsStateToSaveFailed() {
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.save(using: FailingLandmarkStore())
        if case .saveFailed = viewModel.saveState {
            // Expected
        } else {
            Issue.record("Expected .saveFailed, got \(viewModel.saveState)")
        }
    }

}

// MARK: - Test helpers

private struct FailingLandmarkStore: LandmarkStoring {
    func commit(landmark: Landmark) throws {
        throw MapPlusError.noAddressFound
    }
}
