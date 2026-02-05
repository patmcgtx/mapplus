//
//  LandmarksView.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/25/26.
//

import SwiftUI
import SwiftData

struct LandmarksView : View {

    // UI state
    @Environment(\.dismiss) var dismiss
    @State private var showLandmarkForm: Bool = false
    @State private var landmarkToEdit: Landmark? = nil

    // Persistence
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Landmark.name, order: .forward) var landmarks: [Landmark]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(landmarks, id: \.id) { landmark in
                    Button {
                        self.landmarkToEdit = landmark
                    } label: {
                        Label(landmark.name, systemImage: landmark.systemImageName)
                    }
                }
                .onDelete(perform: deleteLandmarks)
            }
            .navigationTitle("My Places")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss", systemImage: "xmark") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Add a place", systemImage: "plus.circle") {
                        self.showLandmarkForm = true
                    }
                }
            }
        }
        .foregroundStyle(.primary) // Set the style for all the forms
        .sheet(isPresented: $showLandmarkForm) {
            NavigationStack {
                LandmarkForm(mode: .create)
            }
        }
        .sheet(item: $landmarkToEdit) { landmark in
            NavigationStack {
                LandmarkForm(mode: .edit(landmark))
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Deletes landmarks at the specified index set from the SwiftData model context.
    ///
    /// - Parameter offsets: The index set indicating which landmarks to delete from the list.
    private func deleteLandmarks(at offsets: IndexSet) {
        let storage = LandmarkStorageService(modelContext: self.modelContext)
        for index in offsets {
            let landmark = landmarks[index]
            try? storage.delete(landmark: landmark)
        }
    }
}

#Preview {
    LandmarksView()
        .modelContainer(try! LandmarkSampleData().inMemorySampleContainer())
}
