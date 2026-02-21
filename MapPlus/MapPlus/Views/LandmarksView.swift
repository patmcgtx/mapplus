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
            .navigationTitle("my-places".localized)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("dismiss".localized, systemImage: "xmark") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("add-place".localized, systemImage: "plus") {
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
        for index in offsets {
            let landmarkToDelete = landmarks[index]
            let store = LandmarkStore(landmark: landmarkToDelete, modelContext: self.modelContext)
            try? store.deleteAndCommit()
        }
    }
}

// MARK: - Previews

#Preview {
    LandmarksView()
        .modelContainer(try! ModelContainer.inMemorySampleContainer())
}
