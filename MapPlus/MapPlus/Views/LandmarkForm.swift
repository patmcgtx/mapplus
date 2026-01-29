//
//  LandmarkForm.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/27/26.
//

import SwiftUI
import CoreLocation
import Contacts
import SFSafeSymbols

import CoreLocation
import Contacts

struct LandmarkForm: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Form state
    @State private var landmarkName: String = "New Place"
    @State private var landmarkIconName: String = "mappin.circle"
    @State private var landmarkAddressInput: String = ""

    private let unknownAddress = "Unknown Address"

    // Location lookup
    private let geocoder = CLGeocoder()
    @State private var isAddressSearchRunning = false
    @State private var resolvedAddressDescription: String = ""
    @State private var resolvedLatitude: CLLocationDegrees = 0.0
    @State private var resolvedLongitude: CLLocationDegrees = 0.0
        
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $landmarkName)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                    NavigationLink {
                        IconPicker(
                            landmarkIconName: $landmarkIconName,
                            iconsToShow: self.iconsToShow
                        )
                    } label: {
                        Label("Icon", systemImage: landmarkIconName)
                    }
                }
                Section("Location") {
                    HStack {
                        TextField(
                            "Address",
                            text: $landmarkAddressInput,
                            onEditingChanged: { _ in
                                self.handleAddressLookup()
                            })
                        Button {
                            self.handleAddressLookup()
                        } label: {
                            Image(systemName: "magnifyingglass")
                        }
                    }
                }
                Section("Preview") {
                    HStack {
                        VStack {
                            Image(systemName: self.landmarkIconName)
                            Text(self.landmarkName)
                        }
                        if (self.isAddressSearchRunning) {
                            ProgressView()
                        } else {
                            Text(self.resolvedAddressDescription)
                        }
                    }
                }
            }
            .navigationTitle(self.landmarkName)
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
        } // NavigationStack
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
    private func handleAddressLookup() {
        if self.isAddressInputValid {
            // Othwerise, go ahead and do the address search
            self.isAddressSearchRunning = true
            self.geocoder.geocodeAddressString(self.landmarkAddressInput) {
                placemarks, error in
                if error != nil {
                    self.resolvedAddressDescription = self.unknownAddress
                } else {
                    self.isAddressSearchRunning = false
                    if let placemark = placemarks?.first {
                        if let lat = placemark.location?.coordinate.latitude,
                           let lon = placemark.location?.coordinate.longitude {
                            self.resolvedLatitude = lat
                            self.resolvedLongitude = lon
                            self.resolvedAddressDescription = placemark.formattedAddress ?? self.unknownAddress
                        }
                    }
                }
            }
        } else {
            // If no address provided, then clear the location data
            self.clearLocation()
        }
    }
    
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
    
    // TODO patmcg consider moving this to its own model/service
    // TODO patmcg add unit tests
    //      - Check some entries
    //      - Check count
    //      - Make sure there are no duplccates (causes UI issues)
    private let iconsToShow: [SFSymbol] = [
        .house,
        .houseFill,
        .musicNoteHouse,
        .houseBadgeWifi,
        .building,
        .buildingColumns,
        .building2,
        .building2CropCircle,
        .dollarsignBankBuilding,
        .mappin,
        .mapCircle,
        .mappinSquare,
        .mappinAndEllipse,
        .cupAndSaucer,
        .cupAndHeatWaves,
        .mug,
        .forkKnife,
        .forkKnifeCircle,
        .car,
        .graduationcap,
        .arcadeStick,
        .arcadeStickConsole,
        .bus,
        .tram,
        .ferry,
        .cablecar,
        .bicycle,
        .fuelpump,
        .person,
        .person2,
        .person3,
        .figureWalk,
        .figureWave,
        .figure,
        .figureStand,
        .figureStandDress,
        .figureAndChildHoldinghands,
        .figure2AndChildHoldinghands,
        .figurePlay,
        .figureRun,
        .figureRoll,
        .figureChild,
        .figureYoga,
        .figureDance,
        .figureKickboxing,
        .figureMindAndBody,
        .figureSkateboarding,
        .figureOpenWaterSwim,
    ]
}

// TODO patmcg consider moving this to its own model/service
// TODO patmcg add unit tests
extension CLPlacemark {
    var formattedAddress: String? {
        // Ensure the postalAddress property is available
        guard let postalAddress = postalAddress else { return nil }
        
        // Use CNPostalAddressFormatter to create a localized string
        let formatter = CNPostalAddressFormatter()
        return formatter.string(from: postalAddress)
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
