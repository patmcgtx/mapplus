//
//  LandmarkForm.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/27/26.
//

import SwiftUI
import SFSafeSymbols

/// A  view for creating or editing landmarks.
struct LandmarkForm: View {
    
    init(
        mode: LandmarkFormViewModel.Mode,
        // TODO patmcg bring these in from the env
        addressLookupService: AddressLookupService = MapKitAddressLookupService(),
        locationService: LocationService = MapKitLocationService()
    ) {
        viewModel = LandmarkFormViewModel(mode: mode)
        self.addressLookupService = addressLookupService
        self.locationService = locationService
    }
    
    // View model owns the form mode and configuration
    private let viewModel: LandmarkFormViewModel
    
    // Location lookup service
    private let addressLookupService: AddressLookupService
    
    // Current location service
    private let locationService: LocationService
    
    // Environment
    @Environment(\.dismiss) private var dismiss
    
    // Persistence
    @Environment(\.modelContext) private var modelContext
    private var storageService: LandmarkStorageService {
        LandmarkStorageService(modelContext: modelContext)
    }
    
    // Form state
    @State private var landmarkNameInput: String = ""
    @State private var landmarkIconNameSelected: String = "mappin.circle"
    @State private var landmarkNotesInput: String = ""
    @State private var landmarkAddressInput: String = ""

    // Icon picker state
    @State private var isShowingIconPicker: Bool = false
    
    // Error state
    private enum SaveState {
        case idle
        case saved
        case failed(Error)
    }
    
    @State private var saveState: SaveState = .idle
    
    // Location lookup state
    private enum AddressSearchState {
        case initial
        case searching
        case resolved(AddressInfo)
        case failed(Error)
    }
    
    @State private var addressSearchState: AddressSearchState = .initial
    
    var body: some View {
        Form {
            saveError
            Section("Details") {
                nameInput
                iconPicker
            }
            Section("Notes") {
                notesInput
            }
            if case .create = viewModel.mode {
                locationSearch
            }
            Section("Preview") {
                previewArea
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                cancelButton
            }
            ToolbarItem(placement: .confirmationAction) {
                saveButton
            }
        }
        .toolbarTitleDisplayMode(.inline)
        .navigationTitle(viewModel.formTitle)
        .sheet(isPresented: $isShowingIconPicker) {
            IconPicker(
                selectedSymbolName: $landmarkIconNameSelected,
                symbolOptions: viewModel.iconsToShow
            )
        }
        .scrollDismissesKeyboard(ScrollDismissesKeyboardMode.immediately)
        .onAppear() {
            switch viewModel.mode {
            case .create:
                break
            case .edit(let landmark):
                // Populate inputs with existing landmark info
                landmarkNameInput = landmark.name
                landmarkIconNameSelected = landmark.systemImageName
                landmarkNotesInput = landmark.notes
                addressSearchState = .resolved(
                    AddressInfo(
                        formattedDescription: landmark.formattedAddress,
                        latitude: landmark.location.latitude,
                        longitude: landmark.location.longitude
                    )
                )
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var saveError: some View {
        switch saveState {
        case .idle, .saved:
            EmptyView()
        case .failed(let error):
            ErrorView(message: "Failed to save", error: error)
        }
    }
    
    private var nameInput: some View {
        HStack {
            TextField("Name", text: $landmarkNameInput,
                      onEditingChanged: { _ in
            })
            .autocorrectionDisabled()
            Button {
                landmarkNameInput = ""
            } label: {
                Image(systemName: "xmark.circle")
            }
        }
    }
    
    private var iconPicker: some View {
        Button {
            isShowingIconPicker = true
        } label: {
            Label("Icon...", systemImage: landmarkIconNameSelected)
        }
    }
    
    private var notesInput: some View {
        TextEditor(text: $landmarkNotesInput)
    }
    
    private var locationSearch: some View {
        Section("Location") {
            HStack {
                TextField(
                    "Address or location name",
                    text: $landmarkAddressInput,
                    onEditingChanged: { _ in
                        lookupAddress()
                    })
                .autocorrectionDisabled()
                Button {
                    lookupAddress()
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                Button {
                    getCurrentLocation()
                } label: {
                    Image(systemName: "location")
                }
            }
        }
    }
    
    private var cancelButton: some View {
        Button("Cancel", systemImage: "x.circle") {
            dismiss()
        }
    }
    
    private var saveButton: some View {
        Button("Save") {
            do {
                switch addressSearchState {
                case .initial, .searching, .failed:
                    break
                case .resolved(let addressInfo):
                    try storageService.save(
                        address: addressInfo,
                        name: landmarkNameInput,
                        notes: landmarkNotesInput,
                        iconName: landmarkIconNameSelected
                    )
                    saveState = .saved
                }
                dismiss()
            } catch {
                saveState = .failed(error)
            }
        }
        .disabled(!isSaveEnabled)
    }
    
    @ViewBuilder
    private var previewArea: some View {
        HStack {
            HStack {
                
                // Landark icon
                VStack {
                    Spacer()
                    Image(systemName: landmarkIconNameSelected)
                    Spacer()
                    Text(landmarkNameInput)
                    Spacer()
                }
                .multilineTextAlignment(.center)
                .padding()
                Spacer()
                
                // Landmark name
                switch addressSearchState {
                case .initial:
                    EmptyView()
                case .searching:
                    ProgressView()
                case .resolved(let addressInfo):
                    Text(addressInfo.formattedDescription)
                case .failed(let error):
                    ErrorView(message: "Location search failed", error: error)
                }
            }
        }
    }
    
    
    // MARK: - Internal helpers
    
    /// Runs and address lookup in the background and updates the UI with the results..
    private func lookupAddress() {
        // TODO patmcg sync this better with getCurrentLocation, possibly combine logic
        Task {
            do {
                let resolvedAddress = try await addressLookupService.lookup(address: landmarkAddressInput)
                await MainActor.run {
                    addressSearchState = .resolved(resolvedAddress)
                    if !landmarkNameInput.isPopulated {
                        landmarkNameInput = resolvedAddress.formattedDescription
                    }
                }
            } catch {
                await MainActor.run {
                    addressSearchState = .failed(error)
                }
            }
        }
    }
    
    /// Gets the user's current location and updates the UI with the results.
    private func getCurrentLocation() {
        // TODO patmcg sync this better with lookupAddress, possibly combine logic
        Task {
            await MainActor.run {
                addressSearchState = .searching
            }
            do {
                let resolvedAddress = try await locationService.getCurrentLocation()
                await MainActor.run {
                    addressSearchState = .resolved(resolvedAddress)
                }
            } catch {
                await MainActor.run {
                    addressSearchState = .failed(error)
                }
            }
        }
    }
    
    private var isSaveEnabled: Bool {
        switch addressSearchState {
        case .initial, .searching, .failed:
            return false
        case .resolved:
            return landmarkNameInput.isPopulated
        }
    }
    
}

#Preview("Create") {
    LandmarkForm(mode: .create)
}

#Preview("Edit") {
    LandmarkForm(
        mode: .edit(LandmarkSampleData().capital)
    )
}

