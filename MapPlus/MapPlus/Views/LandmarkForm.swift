//
//  LandmarkForm.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/27/26.
//

import SwiftUI
import CoreLocation
//import Contacts
import SFSafeSymbols

struct LandmarkForm: View {
        
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    private let viewModel = LandmarkFormViewModel()
    
    // Form state
    @State private var landmarkName: String = ""
    @State private var landmarkIconName: String = "mappin.circle"
    @State private var landmarkAddressInput: String = ""
    @FocusState private var isInputActive: Bool

    // Location lookup
    private let unknownAddress = "Unknown Address"
    private let addressLookupService = AddressLookupService()
    @State private var isAddressSearchRunning = false
    @State private var resolvedAddress = AddressInfo()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    HStack {
                        TextField("Name", text: $landmarkName,
                                  onEditingChanged: { _ in
                            self.isInputActive = false
                        })
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .focused($isInputActive)
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
                Section("Location") {
                    HStack {
                        TextField(
                            "Address",
                            text: $landmarkAddressInput,
                            onEditingChanged: { _ in
                                self.searchAddress()
                            })
                        .focused($isInputActive)
                        .autocorrectionDisabled()
                        Button {
                            self.searchAddress()
                        } label: {
                            Image(systemName: "magnifyingglass")
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
                        self.saveCurrentLandmark()
                    }
                    .disabled(self.isSaveDisabled)
                }
            }
            .toolbarTitleDisplayMode(.inline)
            .navigationTitle("New Place")
        }
        .scrollDismissesKeyboard(ScrollDismissesKeyboardMode.immediately)
    }

    // TODO patmcg consider moving this to its own model/service
    private func saveCurrentLandmark() {
        do {
            let coord = CLLocationCoordinate2D(
                latitude: self.resolvedAddress.latitude,
                longitude: self.resolvedAddress.longitude
            )
            let landmark = Landmark(
                name: self.landmarkName,
                systemImageName: self.landmarkIconName,
                location: coord
            )
            // Insert using the injected modelContext and save with error handling
            self.modelContext.insert(landmark)
            try self.modelContext.save()
            dismiss()
        } catch {
            // You might want to surface this to the user; for now we just log it
            print("Failed to save landmark: \(error)")
        }
    }
    
    // MARK: - Internal helpers
    
    private func searchAddress() {
        Task {
            do {
                let resolved = try await self.addressLookupService.lookup(address: self.landmarkAddressInput)
                await MainActor.run {
                    self.resolvedAddress = resolved
                }
            } catch {
                await MainActor.run {
                    self.resolvedAddress = AddressInfo(
                        formattedDescription: MapPlusError.noAddressFound.errorMessage()
                    )
                }
            }
        }
    }
    
    private var isSaveDisabled: Bool {
        !self.landmarkName.isPopulated || !self.resolvedAddress.formattedDescription.isPopulated
    }

    private var isAddressInputValid: Bool {
        self.landmarkAddressInput.isPopulated && self.landmarkAddressInput != self.unknownAddress
    }
    
}

#Preview {
    LandmarkForm()
}
