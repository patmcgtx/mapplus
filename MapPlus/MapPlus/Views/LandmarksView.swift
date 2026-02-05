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

    // Persistence
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Landmark.name, order: .forward) var landmarks: [Landmark]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(landmarks, id: \.id) { landmark in
                    NavigationLink {
                        LandmarkForm(mode: .edit(landmark))
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
                    .sheet(isPresented: $showLandmarkForm) {
                        LandmarkForm(mode: .create)
                    }
                }
            }
        }
        .foregroundStyle(.primary) // Set the style for all the forms
    }
    
    // MARK: - Helper Methods
    
    /// Deletes landmarks at the specified index set from the SwiftData model context.
    ///
    /// - Parameter offsets: The index set indicating which landmarks to delete from the list.
    private func deleteLandmarks(at offsets: IndexSet) {
        for index in offsets {
            let landmark = landmarks[index]
            modelContext.delete(landmark)
            try? modelContext.save()
        }
    }
}

#Preview {
    LandmarksView()
        .modelContainer(try! LandmarkSampleData().inMemorySampleContainer())
}
