//
//  LandmarkForm.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/27/26.
//

import SwiftUI
import CoreLocation
import SFSafeSymbols

struct LandmarkForm: View {
        
    let mode: LandmarkFormViewModel.Mode
    
    // TODO add mode to view model, derive view model from self.mode
    private let viewModel = LandmarkFormViewModel()

    // Environment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Form state
    @State private var landmarkName: String = ""
    @State private var landmarkIconName: String = "mappin.circle"

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
                        .textInputAutocapitalization(.words)
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
                Section("Location") {
                    HStack {
                        TextField(
                            "Address",
                            text: $landmarkAddressInput,
                            onEditingChanged: { _ in
                                self.searchAddress()
                            })
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
                        self.saveCurrentLandmark()
                    }
                    .disabled(self.isSaveDisabled)
                }
            }
            .toolbarTitleDisplayMode(.inline)
            .navigationTitle(self.viewModel.title(for: self.mode))
        }
        .scrollDismissesKeyboard(ScrollDismissesKeyboardMode.immediately)
        .onAppear() {
            self.landmarkName = self.landmarkToEdit?.name ?? ""
            self.landmarkIconName = self.landmarkToEdit?.systemImageName ?? "mappin.circle"
//            self.resolvedAddress = AddressInfo(formattedDescription: "TODO patmcg")
        }
    }

    private var landmarkToEdit: Landmark? {
        switch self.mode {
        case .create:
            return nil
        case .edit(let landmark):
            return landmark
        }
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
                        formattedDescription: MapPlusError.noAddressFound.errorMessage                    )
                }
            }
        }
    }
    
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
        mode: .edit(
            Landmark(
                name: "Existing Landmark",
                systemImageName: "house",
                location: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
            )
        )
    )
}
