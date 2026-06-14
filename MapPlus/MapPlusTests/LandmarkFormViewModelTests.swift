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

    @Test func testInitialFormFieldsAreEmptyForCreate() {
        let viewModel = LandmarkFormViewModel(mode: .create)
        #expect(viewModel.name == "")
        #expect(viewModel.symbol == "📍")
        #expect(viewModel.notes == "")
        #expect(viewModel.categories.isEmpty)
    }

    @Test func testInitialFormFieldsArePopulatedForEdit() {
        let category = LandmarkCategory(name: "Museums")
        let landmark = Landmark(
            name: "Statue of Liberty",
            notes: "A gift from France",
            formattedAddress: "New York, NY",
            symbol: "🗽",
            categories: [category]
        )
        let viewModel = LandmarkFormViewModel(mode: .edit(landmark))
        #expect(viewModel.name == "Statue of Liberty")
        #expect(viewModel.symbol == "🗽")
        #expect(viewModel.notes == "A gift from France")
        #expect(viewModel.categories.count == 1)
        #expect(viewModel.categories.first?.name == "Museums")
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
        viewModel.addressSearchState = .searchFailed(MapPlusError.locationPermissionDenied)
        #expect(!viewModel.isSaveEnabled)
    }

    @Test func testIsSaveEnabledAfterResolvedWithPopulatedName() {
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.name = "My Place"
        viewModel.addressSearchState = .searchResolved(LocationInfo(briefDescription: "", fullDescription: "", latitude: 0.0, longitude: 0.0))
        #expect(viewModel.isSaveEnabled)
    }

    @Test func testIsSaveEnabledAfterResolvedWithEmptyName() {
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.name = ""
        viewModel.addressSearchState = .searchResolved(LocationInfo(briefDescription: "", fullDescription: "", latitude: 0.0, longitude: 0.0))
        #expect(!viewModel.isSaveEnabled)
    }

    @Test func testIsSaveEnabledAfterResolvedWithWhitespaceOnlyName() {
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.name = "   "
        viewModel.addressSearchState = .searchResolved(LocationInfo(briefDescription: "", fullDescription: "", latitude: 0.0, longitude: 0.0))
        #expect(!viewModel.isSaveEnabled)
    }

    // MARK: - initializeLocation
    
    @Test func testInitializeLocationCreateSuccessDoesNotUpdateLocationSearchInput() async {
        let viewModel = LandmarkFormViewModel(mode: .create)
        let mockService = MockLocationService()

        await viewModel.initializeLocation(
            using: mockService,
            suggestionsService: BasicMapItemSuggestionService(),
            pointOfInterestService: MockPointOfInterestService()
        )

        #expect(viewModel.locationSearchInput == "")
    }

    @Test func testInitializeLocationEditPrePopulatesExistingAddress() async {
        let landmark = Landmark(
            name: "Test",
            formattedAddress: "123 Main St",
            location: .init(latitude: 37.77, longitude: -122.41)
        )
        let viewModel = LandmarkFormViewModel(mode: .edit(landmark))
        let mockService = MockLocationService()

        await viewModel.initializeLocation(
            using: mockService,
            suggestionsService: BasicMapItemSuggestionService(),
            pointOfInterestService: MockPointOfInterestService()
        )

        if case .searchResolved(let info) = viewModel.addressSearchState {
            #expect(info.fullDescription == "123 Main St")
            #expect(info.coordinates.latitude == 37.77)
            #expect(info.coordinates.longitude == -122.41)
        } else {
            Issue.record("Expected .searchResolved, got \(viewModel.addressSearchState)")
        }
    }
    
    @Test func testInitializeLocationWithMultipleNearbyLocations() async {
        let viewModel = LandmarkFormViewModel(mode: .create)
        let mockService = MockLocationService()
        
        // Configure multiple nearby locations
        mockService.locationsToReturn = [
            LocationInfo(
                briefDescription: "Coffee Shop",
                fullDescription: "123 Main St, San Francisco, CA",
                latitude: 37.7749,
                longitude: -122.4194,
                suggestedNotes: "Great coffee!",
                suggestedSymbol: "☕️"
            ),
            LocationInfo(
                briefDescription: "Library",
                fullDescription: "456 Oak Ave, San Francisco, CA",
                latitude: 37.7750,
                longitude: -122.4195,
                suggestedNotes: "Quiet reading space",
                suggestedSymbol: "📚"
            ),
            LocationInfo(
                briefDescription: "Park",
                fullDescription: "789 Park Blvd, San Francisco, CA",
                latitude: 37.7751,
                longitude: -122.4196,
                suggestedNotes: "Nice walking trails",
                suggestedSymbol: "🌳"
            )
        ]
        
        // Use a mock suggestion service that returns our custom data
        let mockSuggestionService = MockMapItemSuggestionService(
            notes: "Great coffee!",
            symbol: "☕️"
        )

        await viewModel.initializeLocation(
            using: mockService,
            suggestionsService: BasicMapItemSuggestionService(),
            pointOfInterestService: MockPointOfInterestService()
        )

        // The first location should be selected
        if case .searchResolved(let info) = viewModel.addressSearchState {
            #expect(info.coordinates.latitude == 37.7749)
            #expect(info.coordinates.longitude == -122.4194)
            #expect(viewModel.symbol == "☕️")
            #expect(viewModel.suggestedNotes == "Great coffee!")
            // Note: fullDescription comes from MapKit's processing of the MKMapItem placemark,
            // not from our original LocationInfo, so we don't assert on it here
        } else {
            Issue.record("Expected .searchResolved, got \(viewModel.addressSearchState)")
        }
    }
    
    @Test func testInitializeLocationWithEmptyCustomAddresses() async {
        let viewModel = LandmarkFormViewModel(mode: .create)
        let mockService = MockLocationService()
        
        // Empty array - no nearby locations
        mockService.locationsToReturn = []

        await viewModel.initializeLocation(
            using: mockService,
            suggestionsService: BasicMapItemSuggestionService(),
            pointOfInterestService: MockPointOfInterestService()
        )

        // Should remain in initial state when no locations found
        if case .searchInitial = viewModel.addressSearchState {
            // Expected
        } else {
            Issue.record("Expected .searchInitial, got \(viewModel.addressSearchState)")
        }
    }
    
    @Test func testMockLocationServiceReturnsMultipleMapItems() async throws {
        let mockService = MockLocationService()
        mockService.locationsToReturn = [
            LocationInfo(
                briefDescription: "Location 1",
                fullDescription: "Address 1",
                latitude: 10.0,
                longitude: 20.0
            ),
            LocationInfo(
                briefDescription: "Location 2",
                fullDescription: "Address 2",
                latitude: 30.0,
                longitude: 40.0
            )
        ]
        
        let mapItems = try await mockService.nearbyMapItems()
        
        #expect(mapItems.count == 2)
        #expect(mapItems[0].name == "Location 1")
        #expect(mapItems[0].placemark.coordinate.latitude == 10.0)
        #expect(mapItems[0].placemark.coordinate.longitude == 20.0)
        #expect(mapItems[1].name == "Location 2")
        #expect(mapItems[1].placemark.coordinate.latitude == 30.0)
        #expect(mapItems[1].placemark.coordinate.longitude == 40.0)
    }
    
    @Test func testMockLocationServiceWithDelay() async throws {
        let mockService = MockLocationService()
        mockService.delaySeconds = 0.1
        mockService.locationsToReturn = [
            LocationInfo(
                briefDescription: "Test Location",
                fullDescription: "Test Address",
                latitude: 10.0,
                longitude: 20.0
            )
        ]
        
        let startTime = Date()
        let mapItems = try await mockService.nearbyMapItems()
        let elapsedTime = Date().timeIntervalSince(startTime)
        
        #expect(mapItems.count == 1)
        #expect(elapsedTime >= 0.1)
    }
    
    @Test func testMockLocationServiceThrowsErrorWhenConfigured() async {
        let mockService = MockLocationService()
        mockService.shouldSucceed = false
        mockService.locationsToReturn = [
            LocationInfo(
                briefDescription: "Test Location",
                fullDescription: "Test Address",
                latitude: 10.0,
                longitude: 20.0
            )
        ]
        
        do {
            _ = try await mockService.nearbyMapItems()
            Issue.record("Expected error to be thrown")
        } catch {
            // Expected
        }
    }

    // MARK: - searchByText

    // TODO patmcg re-enable and fix this test
    @Test func testSearchByTextSuccess() async {
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.locationSearchInput = "San Francisco"
        let mockService = MockAddressLookupService()

        await viewModel.locationTextSearch(
            using: mockService,
            suggestionsService: BasicMapItemSuggestionService(),
            pointOfInterestService: MockPointOfInterestService()
        )

        if case .searchResolved(let info) = viewModel.addressSearchState {
            #expect(viewModel.locationSearchInput == "San Francisco")
            // TODO patmcg fix the check below
//            #expect(info.fullDescription == "San Francisco, CA, United States")
        } else {
            Issue.record("Expected .searchResolved, got \(viewModel.addressSearchState)")
        }
    }

    @Test func testSearchByTextSuccessUpdatesCoordinates() async {
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.locationSearchInput = "San Francisco"
        let mockService = MockAddressLookupService()

        await viewModel.locationTextSearch(
            using: mockService,
            suggestionsService: BasicMapItemSuggestionService(),
            pointOfInterestService: MockPointOfInterestService()
        )

        if case .searchResolved(let info) = viewModel.addressSearchState {
            #expect(info.coordinates.latitude == 37.7752559)
            #expect(info.coordinates.longitude == -122.4191641)
        } else {
            Issue.record("Expected .searchResolved")
        }
    }

    @Test func testSearchByTextFailure() async {
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.locationSearchInput = "Nowhere"
        let mockService = MockAddressLookupService(shouldSucceed: false)

        await viewModel.locationTextSearch(
            using: mockService,
            suggestionsService: BasicMapItemSuggestionService(),
            pointOfInterestService: MockPointOfInterestService()
        )

        if case .searchFailed = viewModel.addressSearchState {
            // Expected
        } else {
            Issue.record("Expected .searchFailed, got \(viewModel.addressSearchState)")
        }
    }

    // MARK: - save

    @Test func testSaveSuccessSetsSaveStateToSaved() throws {
        let container = try ModelContainer(
            for: Landmark.self, LandmarkCategory.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.name = "New Place"
        viewModel.symbol = "📍"
        viewModel.notes = "A great spot"

        viewModel.save(using: LandmarkStore(modelContext: container.mainContext))

        #expect(viewModel.saveState == .saved)
    }

    @Test func testSaveSuccessInsertsLandmarkInContext() throws {
        let container = try ModelContainer(
            for: Landmark.self, LandmarkCategory.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.name = "Persisted Place"
        viewModel.symbol = "🏛️"
        viewModel.notes = "Historical site"
        // Simulate location being resolved
        viewModel.addressSearchState = .searchResolved(
            LocationInfo(
                briefDescription: "",
                fullDescription: "New York, NY",
                latitude: 40.71,
                longitude: -74.00
            )
        )

        viewModel.save(using: LandmarkStore(modelContext: container.mainContext))

        let stored = try container.mainContext.fetch(FetchDescriptor<Landmark>())
        #expect(stored.count == 1)
        #expect(stored.first?.name == "Persisted Place")
        #expect(stored.first?.symbol == "🏛️")
        #expect(stored.first?.notes == "Historical site")
    }

    @Test func testSaveInEditModeUpdatesSaveState() throws {
        let container = try ModelContainer(
            for: Landmark.self, LandmarkCategory.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let landmark = Landmark(name: "Old Name", location: .init(latitude: 51.50, longitude: -0.12))
        container.mainContext.insert(landmark)
        try container.mainContext.save()

        let viewModel = LandmarkFormViewModel(mode: .edit(landmark))
        viewModel.name = "New Name"
        viewModel.symbol = "🏰"

        viewModel.save(using: LandmarkStore(modelContext: container.mainContext))

        #expect(viewModel.saveState == .saved)
        let stored = try container.mainContext.fetch(FetchDescriptor<Landmark>())
        #expect(stored.first?.name == "New Name")
        #expect(stored.first?.symbol == "🏰")
    }

    @Test func testSaveFailureSetsStateToSaveFailed() {
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.name = "Test"
        viewModel.save(using: FailingLandmarkStore())
        if case .saveFailed = viewModel.saveState {
            // Expected
        } else {
            Issue.record("Expected .saveFailed, got \(viewModel.saveState)")
        }
    }
    
    @Test func testSaveAppliesFormFieldsToModel() throws {
        let container = try ModelContainer(
            for: Landmark.self, LandmarkCategory.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let category1 = LandmarkCategory(name: "Parks")
        let category2 = LandmarkCategory(name: "Museums")
        container.mainContext.insert(category1)
        container.mainContext.insert(category2)
        
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.name = "Central Park"
        viewModel.symbol = "🌳"
        viewModel.notes = "Beautiful green space"
        viewModel.categories = [category1, category2]
        viewModel.addressSearchState = .searchResolved(
            LocationInfo(
                briefDescription: "",
                fullDescription: "New York, NY",
                latitude: 40.78,
                longitude: -73.96
            )
        )

        viewModel.save(using: LandmarkStore(modelContext: container.mainContext))

        let stored = try container.mainContext.fetch(FetchDescriptor<Landmark>())
        #expect(stored.count == 1)
        let savedLandmark = try #require(stored.first)
        #expect(savedLandmark.name == "Central Park")
        #expect(savedLandmark.symbol == "🌳")
        #expect(savedLandmark.notes == "Beautiful green space")
        #expect(savedLandmark.categories.count == 2)
    }

    // MARK: - loadCategories
    
    @Test func testLoadCategoriesPopulatesAllCategories() throws {
        let container = try ModelContainer(
            for: Landmark.self, LandmarkCategory.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let category1 = LandmarkCategory(name: "Restaurants")
        let category2 = LandmarkCategory(name: "Museums")
        let category3 = LandmarkCategory(name: "Parks")
        container.mainContext.insert(category1)
        container.mainContext.insert(category2)
        container.mainContext.insert(category3)
        try container.mainContext.save()
        
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.loadCategories(from: container.mainContext)
        
        #expect(viewModel.allCategories.count == 3)
        #expect(viewModel.allCategories.map { $0.name }.sorted() == ["Museums", "Parks", "Restaurants"])
    }
    
    @Test func testLoadCategoriesHandlesEmptyDatabase() throws {
        let container = try ModelContainer(
            for: Landmark.self, LandmarkCategory.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.loadCategories(from: container.mainContext)
        
        #expect(viewModel.allCategories.isEmpty)
    }
    
    // MARK: - addCategory / removeCategory
    
    @Test func testAddCategoryAddsToCategories() {
        let viewModel = LandmarkFormViewModel(mode: .create)
        let category = LandmarkCategory(name: "Favorites")
        
        viewModel.addCategory(category)
        
        #expect(viewModel.categories.count == 1)
        #expect(viewModel.categories.first?.name == "Favorites")
    }
    
    @Test func testRemoveCategoryRemovesFromCategories() {
        let category1 = LandmarkCategory(name: "Favorites")
        let category2 = LandmarkCategory(name: "Visited")
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.categories = [category1, category2]
        
        viewModel.removeCategory(category1)
        
        #expect(viewModel.categories.count == 1)
        #expect(viewModel.categories.first?.name == "Visited")
    }
    
    // MARK: - unassignedCategories
    
    @Test func testUnassignedCategoriesReturnsOnlyUnassigned() {
        let category1 = LandmarkCategory(name: "Restaurants")
        let category2 = LandmarkCategory(name: "Museums")
        let category3 = LandmarkCategory(name: "Parks")
        
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.allCategories = [category1, category2, category3]
        viewModel.categories = [category1]
        
        let unassigned = viewModel.unassignedCategories
        
        #expect(unassigned.count == 2)
        #expect(unassigned.contains(category2))
        #expect(unassigned.contains(category3))
        #expect(!unassigned.contains(category1))
    }
    
    @Test func testUnassignedCategoriesWhenAllAssigned() {
        let category1 = LandmarkCategory(name: "Restaurants")
        let category2 = LandmarkCategory(name: "Museums")
        
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.allCategories = [category1, category2]
        viewModel.categories = [category1, category2]
        
        #expect(viewModel.unassignedCategories.isEmpty)
    }
    
    @Test func testUnassignedCategoriesWhenNoneAssigned() {
        let category1 = LandmarkCategory(name: "Restaurants")
        let category2 = LandmarkCategory(name: "Museums")
        
        let viewModel = LandmarkFormViewModel(mode: .create)
        viewModel.allCategories = [category1, category2]
        viewModel.categories = []
        
        #expect(viewModel.unassignedCategories.count == 2)
    }
    
    // MARK: - applySuggestedNotes
    
    @Test func testApplySuggestedNotesWhenNotesEmpty() async {
        let viewModel = LandmarkFormViewModel(mode: .create)
        let mockLocationService = MockLocationService()
        mockLocationService.locationsToReturn = [LocationInfo(
            briefDescription: "Mock SF",
            fullDescription: "(Mock) San Francisco, CA, United States",
            latitude: 37.7749,
            longitude: -122.4194,
            suggestedNotes: "Suggested notes"
        )]
        
        await viewModel.initializeLocation(
            using: mockLocationService,
            suggestionsService: BasicMapItemSuggestionService(),
            pointOfInterestService: MockPointOfInterestService()
        )

        // Verify notes is empty initially
        #expect(viewModel.notes == "")
        
        // Apply suggested notes
        viewModel.applySuggestedNotes()
        
        // Notes should now contain the suggested notes
        #expect(viewModel.notes == viewModel.suggestedNotes)
    }
    
    @Test func testApplySuggestedNotesWhenNotesNotEmpty() async {
        let viewModel = LandmarkFormViewModel(mode: .create)
        let mockLocationService = MockLocationService()
        mockLocationService.locationsToReturn = [LocationInfo(
            briefDescription: "Mock SF",
            fullDescription: "(Mock) San Francisco, CA, United States",
            latitude: 37.7749,
            longitude: -122.4194,
            suggestedNotes: "Suggested notes"
        )]
        
        await viewModel.initializeLocation(
            using: mockLocationService,
            suggestionsService: BasicMapItemSuggestionService(),
            pointOfInterestService: MockPointOfInterestService()
        )

        // Set existing notes
        viewModel.notes = "My existing notes"
        
        let expectedSuggestedNotes = viewModel.suggestedNotes
        
        // Apply suggested notes
        viewModel.applySuggestedNotes()
        
        // Notes should have suggested notes appended with two newlines
        #expect(viewModel.notes == "My existing notes\n\n\(expectedSuggestedNotes)")
    }
    
    @Test func testApplySuggestedNotesMultipleTimes() async {
        let viewModel = LandmarkFormViewModel(mode: .create)
        let mockLocationService = MockLocationService()
        mockLocationService.locationsToReturn = [LocationInfo(
            briefDescription: "Mock SF",
            fullDescription: "(Mock) San Francisco, CA, United States",
            latitude: 37.7749,
            longitude: -122.4194,
            suggestedNotes: "Suggested notes"
        )]
        
        // Initialize location to populate suggestedNotes
        await viewModel.initializeLocation(
            using: mockLocationService,
            suggestionsService: BasicMapItemSuggestionService(),
            pointOfInterestService: MockPointOfInterestService()
        )

        // Set existing notes
        viewModel.notes = "My existing notes"
        
        let expectedSuggestedNotes = viewModel.suggestedNotes
        
        // Apply suggested notes
        viewModel.applySuggestedNotes()
        
        // Notes should have suggested notes appended with two newlines
        #expect(viewModel.notes == "My existing notes\n\n\(expectedSuggestedNotes)")

        // Apply suggested notes again
        viewModel.applySuggestedNotes()
        
        // Notes should have suggested notes appended with two newlines
        #expect(viewModel.notes == "My existing notes\n\n\(expectedSuggestedNotes)\n\n\(expectedSuggestedNotes)")
    }
    
    @Test func testApplySuggestedNotesWhenSuggestedNotesEmpty() {
        let viewModel = LandmarkFormViewModel(mode: .create)
        
        // suggestedNotes is empty by default (no location initialized)
        #expect(viewModel.suggestedNotes == "")
        
        viewModel.notes = "My notes"
        viewModel.applySuggestedNotes()
        
        // Should append empty string with separator
        #expect(viewModel.notes == "My notes\n\n")
    }

}

// MARK: - Test helpers

private struct FailingLandmarkStore: LandmarkStoring {
    struct SaveError: Error {}
    func commit(landmark: Landmark) throws {
        throw SaveError()
    }
    func delete(landmark: Landmark) throws {
        throw SaveError()
    }
}
