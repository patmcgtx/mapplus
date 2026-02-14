//
//  LandmarkForm.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/27/26.
//

import SwiftUI
import SFSafeSymbols

// TODO patmcg doc
struct LandmarkForm: View {

    // TODO patmcg use that private var trick to make the view elements easier to understand

    init(
        mode: LandmarkFormViewModel.Mode,
        // TODO patmcg bring these in from the env
        addressLookupService: AddressLookupService = MapKitAddressLookupService(),
        locationService: LocationService = MapKitLocationService()
    ) {
        self.viewModel = LandmarkFormViewModel(mode: mode)
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
        LandmarkStorageService(modelContext: self.modelContext)
    }
    
    // Form state
    @State private var landmarkName: String = ""
    @State private var landmarkIconName: String = "mappin.circle"
    @State private var landmarkNotes: String = ""
    
    // Icon picker state
    @State private var showingIconPicker: Bool = false
    
    // Error state
    @State private var showingSaveError: Bool = false
    @State private var saveErrorMessage: String = ""

    // Location lookup state
    private enum AddressSearchState {
        case idle
        case loading
        case resolved(AddressInfo)
        case error(Error)
    }
    @State private var addressSearchState: AddressSearchState = .idle
    @State private var landmarkAddressInput: String = ""
    @State private var isAddressSearchRunning = false
    @State private var resolvedAddress = AddressInfo()
    
    var body: some View {
        Form {
            Section("Details") {
                nameInput
                iconPicker
            }
            Section("Notes") {
                notesInput
            }
            if case .create = self.viewModel.mode {
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
        .navigationTitle(self.viewModel.formTitle)
        .alert("Oops", isPresented: $showingSaveError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(saveErrorMessage.isEmpty ? "Failed to save" : saveErrorMessage)
        }
        .sheet(isPresented: $showingIconPicker) {
            IconPicker(
                selectedSymbolName: $landmarkIconName,
                symbolOptions: viewModel.iconsToShow
            )
        }
        .scrollDismissesKeyboard(ScrollDismissesKeyboardMode.immediately)
        .onAppear() {
            if let landmark = self.viewModel.landmarkToEdit {
                self.landmarkName = landmark.name
                self.landmarkIconName = landmark.systemImageName
                self.landmarkNotes = landmark.notes
                self.resolvedAddress = AddressInfo(
                    formattedDescription: landmark.formattedAddress,
                    latitude: landmark.location.latitude,
                    longitude: landmark.location.longitude
                )
            }
        }
    }
    
    // MARK: - Subviews
    
    private var nameInput: some View {
        HStack {
            TextField("Name", text: $landmarkName,
                      onEditingChanged: { _ in
            })
            .autocorrectionDisabled()
            Button {
                self.landmarkName = ""
            } label: {
                Image(systemName: "xmark.circle")
            }
        }
    }
    
    private var iconPicker: some View {
        Button {
            self.showingIconPicker = true
        } label: {
            Label("Icon...", systemImage: landmarkIconName)
        }
    }
    
    private var notesInput: some View {
        TextEditor(text: $landmarkNotes)
    }
    
    private var locationSearch: some View {
        Section("Location") {
            HStack {
                TextField(
                    "Address or location name",
                    text: $landmarkAddressInput,
                    onEditingChanged: { _ in
                        self.lookupAddress()
                    })
                .autocorrectionDisabled()
                Button {
                    self.lookupAddress()
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                Button {
                    self.getCurrentLocation()
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
                try self.storageService.save(
                    address: self.resolvedAddress,
                    name: self.landmarkName,
                    notes: self.landmarkNotes,
                    iconName: self.landmarkIconName
                )
                self.dismiss()
            } catch {
                self.saveErrorMessage = error.localizedDescription
                self.showingSaveError = true
            }
        }
        .disabled(self.isSaveDisabled)
    }
    
    private var previewArea: some View {
        HStack {
            HStack {
                VStack {
                    Spacer()
                    Image(systemName: self.landmarkIconName)
                    Spacer()
                    Text(self.landmarkName)
                    Spacer()
                }
                .multilineTextAlignment(.center)
                .padding()
                Spacer()
                if (self.isAddressSearchRunning) {
                    ProgressView()
                } else {
                    Text(self.resolvedAddress.formattedDescription)
                }
                Spacer()
            }
            .padding()
        }
    }
    
    
    // MARK: - Internal helpers
    
    /// Runs and address lookup in the background and updates the UI with the results..
    private func lookupAddress() {
        // TODO patmcg clean up search state and coordinate with address search
        Task {
            do {
                let resolved = try await self.addressLookupService.lookup(address: self.landmarkAddressInput)
                await MainActor.run {
                    self.resolvedAddress = resolved
                }
            } catch {
                await MainActor.run {
                    self.resolvedAddress = AddressInfo(
                        formattedDescription: MapPlusError.noAddressFound.errorMessage                    )
                }
            }
        }
    }
    
    /// Gets the user's current location and updates the UI with the results.
    private func getCurrentLocation() {
        // TODO patmcg clean up search state and coordinate with current location
        Task {
            await MainActor.run {
                self.isAddressSearchRunning = true
            }
            do {
                let resolved = try await self.locationService.getCurrentLocation()
                await MainActor.run {
                    self.resolvedAddress = resolved
                    self.landmarkAddressInput = resolved.formattedDescription
                    self.isAddressSearchRunning = false
                }
            } catch {
                await MainActor.run {
                    self.resolvedAddress = AddressInfo(
                        formattedDescription: MapPlusError.noAddressFound.errorMessage
                    )
                    self.isAddressSearchRunning = false
                }
            }
        }
    }
    
    // TODO patmcg fix this validation logic
    private var isSaveDisabled: Bool {
        !self.landmarkName.isPopulated || !self.resolvedAddress.formattedDescription.isPopulated
    }

    // TODO patmcg fix this validation logic
    private var isAddressInputValid: Bool {
        self.landmarkAddressInput.isPopulated && self.landmarkAddressInput != MapPlusError.noAddressFound.errorMessage
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
    
