//
//  LandmarkForm.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/27/26.
//

import SwiftUI
import SFSafeSymbols

struct LandmarkForm: View {
        
    /// Are we creating a new landmark or editing an existing one?
    let mode: LandmarkFormViewModel.Mode

    private let viewModel = LandmarkFormViewModel()

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
                if case .create = self.mode  {
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
                            try LandmarkStorageService().save(
                                address: self.resolvedAddress,
                                inContext: self.modelContext,
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
            .navigationTitle(self.viewModel.title(for: self.mode))
            .alert("Oops", isPresented: $showingSaveError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(saveErrorMessage.isEmpty ? "Failed to save" : saveErrorMessage)
            }
        }
        .scrollDismissesKeyboard(ScrollDismissesKeyboardMode.immediately)
        .onAppear() {
            self.landmarkName = self.landmarkInEdit?.name ?? ""
            self.landmarkIconName = self.landmarkInEdit?.systemImageName ?? "mappin.circle"
            if let landmark = self.landmarkInEdit {
                self.resolvedAddress = AddressInfo(
                    formattedDescription: landmark.formattedAddress,
                    latitude: landmark.location.latitude,
                    longitude: landmark.location.longitude
                )
            }
        }
    }
    
    
    // MARK: - Internal helpers

    /// What landmark are we editing, if any?
    private var landmarkInEdit: Landmark? {
        switch self.mode {
        case .create:
            return nil
        case .edit(let landmark):
            return landmark
        }
    }
    
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
    
