//
//  LandmarkFormViewModel.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//
import SwiftData
import CoreData

/// View model that provides state and logic for `LandmarkForm`.
@Observable @MainActor
final class LandmarkFormViewModel {

    /// Indicates how the form is being used.
    /// - Note: In `create` mode, there is no backing landmark yet; in `edit` mode,
    ///         the provided `Landmark` supplies initial values.
    enum Mode {
        /// Create a brand new landmark.
        case create
        /// Edit an existing landmark.
        case edit(Landmark)
    }

    /// Represents the current state of the location/address search.
    enum AddressSearchState: Equatable {
        case searchInitial
        case searching
        case searchResolved(LocationInfo)
        case searchFailed(Error)

        static func == (lhs: AddressSearchState, rhs: AddressSearchState) -> Bool {
            switch (lhs, rhs) {
            case (.searchInitial, .searchInitial), (.searching, .searching):
                return true
            case (.searchResolved(let a), .searchResolved(let b)):
                return a.briefDescription == b.briefDescription &&
                       a.fullDescription == b.fullDescription &&
                       a.coordinates.latitude == b.coordinates.latitude &&
                       a.coordinates.longitude == b.coordinates.longitude
            case (.searchFailed(let e1), .searchFailed(let e2)):
                return type(of: e1) == type(of: e2)
            default:
                return false
            }
        }
    }

    /// Represents the current state of saving the landmark.
    enum SaveState: Equatable {
        case saveInitial
        case saved
        case saveFailed(Error)

        static func == (lhs: SaveState, rhs: SaveState) -> Bool {
            switch (lhs, rhs) {
            case (.saveInitial, .saveInitial), (.saved, .saved):
                return true
            case (.saveFailed(let error1), .saveFailed(let error2)):
                return type(of: error1) == type(of: error2)
            default:
                return false
            }
        }
    }

    /// The current mode for the form
    let mode: Mode

    /// The landmark being edited (private - not exposed to view)
    private var landmarkToEdit: Landmark

    /// The current state of the address/location search
    var addressSearchState: AddressSearchState = .searchInitial

    /// The current state of the save operation
    var saveState: SaveState = .saveInitial

    /// The text entered in the location search field
    var locationSearchInput: String = ""

    // MARK: - Form Fields (exposed to view via bindings)
    
    /// The landmark's name
    var name: String = ""
    
    /// The landmark's symbol
    var symbol: String = "📍"
    
    /// The landmark's notes
    var notes: String = ""
    
    /// The landmark's categories
    var categories: [LandmarkCategory] = []
    
    /// All available categories (loaded from persistence)
    var allCategories: [LandmarkCategory] = []

    init(mode: Mode) {
        self.mode = mode
        switch mode {
        case .create:
            landmarkToEdit = Landmark()
        case .edit(let landmark):
            landmarkToEdit = landmark
            // Populate form fields from existing landmark
            name = landmark.name
            symbol = landmark.symbol
            notes = landmark.notes
            categories = landmark.categories
        }
    }

    /// Loads available categories from persistence
    /// - Parameter context: The context to fetch categories from
    func loadCategories(from context: ModelContext) {
        let descriptor = FetchDescriptor<LandmarkCategory>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        allCategories = (try? context.fetch(descriptor)) ?? []
    }

    /// Saves any changes made to the form fields and updates `saveState`.
    /// - Parameter store: The store used to commit the landmark.
    func save(using store: any LandmarkStoring) {
        // Apply form fields to the model
        landmarkToEdit.name = name
        landmarkToEdit.symbol = symbol
        landmarkToEdit.notes = notes
        landmarkToEdit.categories = categories
        
        do {
            try store.commit(landmark: landmarkToEdit)
            saveState = .saved
        } catch {
            saveState = .saveFailed(error)
        }
    }
    
    /// Adds a category to the landmark
    /// - Parameter category: The category to add
    func addCategory(_ category: LandmarkCategory) {
        guard !categories.contains(where: { $0.id == category.id }) else { return }
        categories.append(category)
        categories.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    /// Removes a category from the landmark
    /// - Parameter category: The category to remove
    func removeCategory(_ category: LandmarkCategory) {
        categories.removeAll { $0.id == category.id }
    }

    /// The title to display at the top of the form.
    ///
    /// - Returns: "New Landmark" when creating, or the existing landmark's name when editing.
    var formTitle: String {
        switch mode {
        case .create:
            return "new-landmark".localized
        case .edit(let landmark):
            return landmark.name
        }
    }

    /// Whether the Save button should be enabled.
    var isSaveEnabled: Bool {
        guard name.isPopulated else { return false }
        
        switch addressSearchState {
        case .searchInitial, .searching, .searchFailed:
            return false
        case .searchResolved:
            return true
        }
    }
    
    /// Categories not yet assigned to this landmark
    var unassignedCategories: [LandmarkCategory] {
        allCategories.filter { !categories.contains($0) }
    }

    /// Initializes the location state based on the current form mode.
    ///
    /// In create mode, attempts to pre-populate the current device location.
    /// In edit mode, resolves the landmark's existing address.
    ///
    /// - Parameter locationService: The service used to fetch the current device location.
    func initializeLocation(using locationService: any LocationService) async {
        switch mode {
        case .create:
            do {
                let resolvedAddress = try await locationService.getCurrentLocation()
                applyResolvedAddress(resolvedAddress, updateSearchInput: false)
            } catch {
                // Not a reportable error if this fails; just let them proceed as normal
            }
        case .edit:
            addressSearchState = .searchResolved(
                LocationInfo(
                    briefDescription: landmarkToEdit.name,
                    fullDescription: landmarkToEdit.formattedAddress,
                    latitude: landmarkToEdit.location.latitude,
                    longitude: landmarkToEdit.location.longitude
                )
            )
        }
    }

    /// Looks up the address entered in `locationSearchInput` and updates location state.
    /// - Parameter addressLookupService: The service used to perform the address lookup.
    func searchByText(using addressLookupService: any AddressLookupService) async {
        addressSearchState = .searching
        do {
            let resolvedAddress = try await addressLookupService.lookup(address: locationSearchInput)
            applyResolvedAddress(resolvedAddress, updateSearchInput: true)
        } catch {
            addressSearchState = .searchFailed(error)
        }
    }

    /// Fetches the current device location and updates location state.
    /// - Parameter locationService: The service used to get the current location.
    func searchByCurrentLocation(using locationService: any LocationService) async {
        addressSearchState = .searching
        do {
            let resolvedAddress = try await locationService.getCurrentLocation()
            applyResolvedAddress(resolvedAddress, updateSearchInput: true)
        } catch {
            addressSearchState = .searchFailed(error)
        }
    }

    // MARK: - Private helpers

    /// Applies a resolved address to the landmark and updates the search state.
    /// - Parameters:
    ///   - address: The resolved location to apply.
    ///   - updateSearchInput: When `true`, also updates `locationSearchInput` to the resolved description.
    private func applyResolvedAddress(_ address: LocationInfo, updateSearchInput: Bool) {
        addressSearchState = .searchResolved(address)
        landmarkToEdit.formattedAddress = address.fullDescription
        landmarkToEdit.latitude = address.coordinates.latitude
        landmarkToEdit.longitude = address.coordinates.longitude
    }

}
