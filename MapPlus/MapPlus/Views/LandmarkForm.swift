//
//  LandmarkForm.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/27/26.
//

import SwiftUI
import CoreLocation


struct LandmarkForm: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // Form state
    @State private var name: String = "Bath & Body Works"
    @State private var systemImageName: String = "bag"
    @State private var latitude: String = "30.230825"
    @State private var longitude: String = "-97.799609"

    // Simple validation
    private var isSaveDisabled: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        Double(latitude) == nil ||
        Double(longitude) == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                    TextField("Image Name", text: $systemImageName)
                        .autocorrectionDisabled()
                }
                Section("Location") {
                    TextField("Latitude", text: $latitude)
                        .keyboardType(.numbersAndPunctuation)
                    TextField("Longitude", text: $longitude)
                        .keyboardType(.numbersAndPunctuation)
                }
            }
            .navigationTitle("New Landmark")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        do {
                            guard let lat = Double(self.latitude), let lon = Double(self.longitude) else { return }
                            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                            let landmark = Landmark(
                                name: self.name,
                                systemImageName: self.systemImageName,
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
