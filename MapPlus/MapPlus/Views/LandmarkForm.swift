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
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Form state
    @State private var landmarkName: String = "New Place"
    @State private var landmarkIconName: String = "mappin.circle.fill"
    @State private var landmarkAddressInput: String = ""

    @State private var landmarkActualAddress: String = ""

    // Location lookup
    private let geocoder = CLGeocoder()
    @State private var latitude: CLLocationDegrees = 0.0
    @State private var longitude: CLLocationDegrees = 0.0
    
    // Simple validation
    private var isSaveDisabled: Bool {
        landmarkName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
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
                        Label("Pick icon", systemImage: landmarkIconName)
                    }
                }
                Section("Location") {
                    TextField(
                        "Address",
                        text: $landmarkAddressInput,
                        onEditingChanged: { newValue in
                            // TODO patmcg consider moving this to its own model/service
                            self.geocoder.geocodeAddressString(self.landmarkAddressInput) { placemarks, error in
                                let placemark = placemarks?.first
                                if let lat = placemark?.location?.coordinate.latitude,
                                   let lon = placemark?.location?.coordinate.longitude {
                                    self.latitude = lat
                                    self.longitude = lon
                                    self.landmarkActualAddress = placemark?.name ?? "Unknown Address"
                                }
                            }
                    })
                    Text(self.landmarkActualAddress)
                }
            }
            .navigationTitle(landmarkName)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // TODO patmcg consider sending this to a view model
                        do {
                            let coord = CLLocationCoordinate2D(
                                latitude: self.latitude,
                                longitude: self.longitude
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
                    .disabled(
                        isSaveDisabled
                    )
                }
            }
        }
    }
    
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

#Preview {
    LandmarkForm()
}
