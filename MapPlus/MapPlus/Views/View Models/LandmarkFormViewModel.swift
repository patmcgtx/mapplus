//
//  LandmarkFormViewModel.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//
import SwiftData

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
    enum AddressSearchState {
        case searchInitial
        case searching
        case searchResolved(LocationInfo)
        case searchFailed(Error)
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
            case (.saveFailed, .saveFailed):
                return true
            default:
                return false
            }
        }
    }

    /// The current mode for the form
    let mode: Mode

    /// The landmark to edit in this form
    var landmarkToEdit: Landmark

    /// The current state of the address/location search
    var addressSearchState: AddressSearchState = .searchInitial

    /// The current state of the save operation
    var saveState: SaveState = .saveInitial

    /// The text entered in the location search field
    var locationSearchInput: String = ""

    init(mode: Mode) {
        self.mode = mode
        switch mode {
        case .create:
            landmarkToEdit = Landmark()
        case .edit(let landmark):
            landmarkToEdit = landmark
        }
    }

    /// Saves any changes made to `landmarkToEdit` and updates `saveState`.
    /// - Parameter context: The persistent context in which to save the landmark
    func save(context: ModelContext) {
        do {
            try LandmarkStore(modelContext: context)
                .commit(landmark: landmarkToEdit)
            saveState = .saved
        } catch {
            saveState = .saveFailed(error)
        }
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
        switch addressSearchState {
        case .searchInitial, .searching, .searchFailed:
            return false
        case .searchResolved:
            return landmarkToEdit.name.isPopulated
        }
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
                    formattedDescription: landmarkToEdit.formattedAddress,
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
        if updateSearchInput {
            locationSearchInput = address.formattedDescription
        }
        landmarkToEdit.formattedAddress = address.formattedDescription
        landmarkToEdit.latitude = address.coordinates.latitude
        landmarkToEdit.longitude = address.coordinates.longitude
    }

}
