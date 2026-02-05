//
//  LandmarkForm.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/27/26.
//

import SwiftUI
import SFSafeSymbols

struct LandmarkForm: View {
        
    init(mode: LandmarkFormViewModel.Mode) {
        self.viewModel = LandmarkFormViewModel(mode: mode)
    }
    
    // View model owns the form mode and configuration
    private let viewModel: LandmarkFormViewModel

    // Environment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Form state
    @State private var landmarkName: String = ""
    @State private var landmarkIconName: String = "mappin.circle"
    
    // Error state
    @State private var showingSaveError: Bool = false
    @State private var saveErrorMessage: String = ""

    // Location lookup
    private let addressLookupService = AddressLookupService()
    @State private var landmarkAddressInput: String = ""
    @State private var isAddressSearchRunning = false
    @State private var resolvedAddress = AddressInfo()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
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
                    NavigationLink {
                        IconPicker(
                            landmarkIconName: $landmarkIconName,
                            iconsToShow: viewModel.iconsToShow
                        )
                    } label: {
                        Label("Icon...", systemImage: landmarkIconName)
                    }
                }
                if case .create = self.viewModel.mode  {
                    Section("Location") {
                        HStack {
                            TextField(
                                "Address",
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
                        }
                    }
                }
                Section("Preview") {
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
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "x.circle") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        do {
                            let landmarkStorage = LandmarkStorageService(
                                modelContext: self.modelContext
                            )
                            try landmarkStorage.save(
                                address: self.resolvedAddress,
                                withName: self.landmarkName,
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
            }
            .toolbarTitleDisplayMode(.inline)
            .navigationTitle(self.viewModel.formTitle)
            .alert("Oops", isPresented: $showingSaveError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(saveErrorMessage.isEmpty ? "Failed to save" : saveErrorMessage)
            }
        }
        .scrollDismissesKeyboard(ScrollDismissesKeyboardMode.immediately)
        .onAppear() {
            self.landmarkName = self.viewModel.landmarkName
            self.landmarkIconName = self.viewModel.landmarkIconName
            if let landmark = self.viewModel.landmarkToEdit {
                self.resolvedAddress = AddressInfo(
                    formattedDescription: landmark.formattedAddress,
                    latitude: landmark.location.latitude,
                    longitude: landmark.location.longitude
                )
            }
        }
    }
    
    
    // MARK: - Internal helpers
    
    /// Runs and address lookup in the background and updates the UI with the results..
    private func lookupAddress() {
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
    
    // TODO patmcg fix this logic
    private var isSaveDisabled: Bool {
        !self.landmarkName.isPopulated || !self.resolvedAddress.formattedDescription.isPopulated
    }

    private var isAddressInputValid: Bool {
        self.landmarkAddressInput.isPopulated && self.landmarkAddressInput != MapPlusError.noAddressFound.errorMessage
    }
    
}

#Preview("Create") {
    LandmarkForm(mode: .create)
}

#Preview("Edit") {
    LandmarkForm(
        mode: .edit(LandmarkSampleData().sampleData.first!)
    )
}
    
