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
    @State private var landmarkAddress: String = ""
    
    @State private var latitude: String = "30.230825"
    @State private var longitude: String = "-97.799609"
    
    // Simple validation
    private var isSaveDisabled: Bool {
        landmarkName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        Double(latitude) == nil ||
        Double(longitude) == nil
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
                    TextField("Latitude", text: $latitude)
                        .keyboardType(.numbersAndPunctuation)
                    TextField("Longitude", text: $longitude)
                        .keyboardType(.numbersAndPunctuation)
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
                            guard let lat = Double(self.latitude), let lon = Double(self.longitude) else { return }
                            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
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
