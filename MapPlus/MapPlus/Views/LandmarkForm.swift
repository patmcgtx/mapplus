//
//  LandmarkForm.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/27/26.
//

import SwiftUI
import CoreLocation


struct LandmarkForm: View {
    // Callback to deliver the newly created Landmark to a parent view
    var onSave: (Landmark) -> Void = { _ in }

    @Environment(\.dismiss) private var dismiss

    // Form state
    @State private var name: String = ""
    @State private var category: String = ""
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    @State private var notes: String = ""

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
                    TextField("Category", text: $category)
                        .textInputAutocapitalization(.words)
                }

                Section("Location") {
                    TextField("Latitude", text: $latitude)
                        .keyboardType(.numbersAndPunctuation)
                    TextField("Longitude", text: $longitude)
                        .keyboardType(.numbersAndPunctuation)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.2))
                        )
                }
            }
            .navigationTitle("New Landmark")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(isSaveDisabled)
                }
            }
        }
    }

    private func save() {
        guard let lat = Double(latitude), let lon = Double(longitude) else { return }
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let landmark = Landmark(
            name: "String",
            systemImageName: "String",
            location: coord
        )
        onSave(landmark)
        dismiss()
    }
}

#Preview {
    LandmarkForm { landmark in
        print("Saved landmark: \(landmark)")
    }
}
