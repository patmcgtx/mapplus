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
    
    private let addressLookupService = AddressLookupService()
    private let viewModel = LandmarkFormViewModel()
    
    // Form state
    @State private var landmarkName: String = ""
    @State private var landmarkIconName: String = "mappin.circle"
    @State private var landmarkAddressInput: String = ""
    @FocusState private var isInputActive: Bool

    private let unknownAddress = "Unknown Address"

    // Location lookup
//    private let geocoder = CLGeocoder()
    @State private var isAddressSearchRunning = false
    @State private var resolvedAddressDescription: String = ""
    @State private var resolvedLatitude: CLLocationDegrees = 0.0
    @State private var resolvedLongitude: CLLocationDegrees = 0.0
        
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
                                Task {
                                    let resolvedLocation = try await self.addressLookupService.lookup(address: self.landmarkAddressInput)
                                    await MainActor.run {
                                        self.resolvedAddressDescription = resolvedLocation.formattedDescription
                                    }
                                }
                            })
                        .focused($isInputActive)
                        .autocorrectionDisabled()
                        Button {
                            Task {
                                let resolvedLocation = try await self.addressLookupService.lookup(address: self.landmarkAddressInput)
                                await MainActor.run {
                                    self.resolvedAddressDescription = resolvedLocation.formattedDescription
                                }
                            }
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
                                Text(self.resolvedAddressDescription)
                            }
                            Spacer()
                        }
                        .padding()
                    }
                }
            } // Form
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
                } // ToolbarItem / confirmation
            } // .toolbar
            .toolbarTitleDisplayMode(.inline)
            .navigationTitle("New Place")
        } // NavigationStack
        .scrollDismissesKeyboard(ScrollDismissesKeyboardMode.immediately)
    } // body

    // TODO patmcg consider moving this to its own model/service
    private func saveCurrentLandmark() {
        do {
            let coord = CLLocationCoordinate2D(
                latitude: self.resolvedLatitude,
                longitude: self.resolvedLongitude
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
    
    // TODO patmcg consider moving this to its own model/service
//    private func handleAddressLookup() {
//        if self.isAddressInputValid {
//            // Othwerise, go ahead and do the address search
//            self.isInputActive = false
//            self.isAddressSearchRunning = true
//            self.geocoder.geocodeAddressString(self.landmarkAddressInput) {
//                placemarks, error in
//                if error != nil {
//                    self.resolvedAddressDescription = self.unknownAddress
//                } else {
//                    self.isAddressSearchRunning = false
//                    if let placemark = placemarks?.first {
//                        if let lat = placemark.location?.coordinate.latitude,
//                           let lon = placemark.location?.coordinate.longitude {
//                            self.resolvedLatitude = lat
//                            self.resolvedLongitude = lon
//                            self.resolvedAddressDescription = placemark.formattedAddress ?? self.unknownAddress
//                        }
//                    }
//                }
//            }
//        } else {
//            // If no address provided, then clear the location data
//            self.clearLocation()
//        }
//    }
    
    // TODO patmcg challenge - how to unit test this private logic?
    //      Or does it really have to be UI tests?  Can I ise ViewInspector?
    
    // Simple validation
    private var isSaveDisabled: Bool {
        !self.landmarkName.isPopulated || !self.resolvedAddressDescription.isPopulated
    }

    private var isAddressInputValid: Bool {
        self.landmarkAddressInput.isPopulated && self.landmarkAddressInput != self.unknownAddress
    }
    
    private func clearLocation() {
        self.resolvedLatitude = 0.0
        self.resolvedLongitude = 0.0
        self.resolvedAddressDescription = ""
    }
    
}

// TODO patmcg add unit tests
extension String {
    var isPopulated: Bool {
        !trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

#Preview {
    LandmarkForm()
}
