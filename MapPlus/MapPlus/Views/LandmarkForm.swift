//
//  LandmarkForm.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/27/26.
//

import SwiftUI
import CoreLocation
import SFSymbolsPicker

struct LandmarkForm: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // Form state
    @State private var landmarkName: String = "New Place"
    @State private var landmarkIconName: String = "mappin.circle.fill"
    @State private var latitude: String = "30.230825"
    @State private var longitude: String = "-97.799609"
    @State private var isIconSelectorPresented = false

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
                    Button("Pick icon", systemImage: landmarkIconName) {
                        self.isIconSelectorPresented.toggle()
                    }
                }
                .sheet(isPresented: $isIconSelectorPresented) {
                    SymbolsPicker(selection: $landmarkIconName, titleKey: "Pick an Icon", autoDismiss: true)
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
        } // NavigationStack
    } // body
} // View

#Preview {
    LandmarkForm()
}
