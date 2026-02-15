//
//  LandmarksView.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/25/26.
//

import SwiftUI
import SwiftData

// TODO patmcg doc
struct LandmarksView : View {

    // Environment
    @Environment(\.dismiss) var dismiss

    // UI state
    @State private var showLandmarkForm: Bool = false
    @State private var landmarkToEdit: Landmark? = nil

    // Persistence
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Landmark.name, order: .forward) var landmarks: [Landmark]
    
    private var storageService: LandmarkStorageService {
        LandmarkStorageService(modelContext: self.modelContext)
    }
    
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
            .navigationTitle("My Places".localized)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss".localized, systemImage: "xmark") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Add a place".localized, systemImage: "plus.circle") {
                        self.showLandmarkForm = true
                    }
                }
            }
        }
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
        let storage = self.storageService
        for index in offsets {
            let landmark = landmarks[index]
            try? storage.delete(landmark: landmark)
        }
    }
}

// MARK: - Previews

#Preview {
    LandmarksView()
        .modelContainer(try! ModelContainer.inMemorySampleContainer())
}
