//
//  LandmarksView.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/25/26.
//

import SwiftUI
import SwiftData

/// Displays an editable list of landmarks
struct LandmarksView : View {

    // MARK: Environment
    
    @Environment(\.dismiss)
    var dismiss
    
    // MARK: Persistence
    @Environment(\.modelContext)
    private var modelContext
    
    @Query(sort: \Landmark.name, order: .forward)
    var landmarks: [Landmark]
    
    // MARK: View state

    @State
    private var showLandmarkForm: Bool = false
    
    @State
    private var landmarkToEdit: Landmark? = nil
    
    @State
    private var didDeleteLandmark: Bool = false
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(landmarks) { landmark in
                    Button {
                        self.landmarkToEdit = landmark
                    } label: {
                        HStack {
                            Text(landmark.symbol)
                            Text(landmark.name)
                        }
                    }
                }
                .onDelete(perform: deleteLandmarks)
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: didDeleteLandmark)
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
    
    // MARK: Private helpers
    
    /// Deletes landmarks at the specified index set from the SwiftData model context.
    ///
    /// - Parameter offsets: The index set indicating which landmarks to delete from the list.
    private func deleteLandmarks(at offsets: IndexSet) {
        
        // TODO patmcg can we call LandmarkStorage instead if this method?
        
        for index in offsets {
            let landmarkToDelete = landmarks[index]
            let store = LandmarkStore(modelContext: self.modelContext)
            try? store.delete(landmark: landmarkToDelete)
        }
        didDeleteLandmark.toggle()
    }
}

#if DEBUG

// MARK: - Previews

#Preview {
    LandmarksView()
        .modelContainer(try! ModelContainer.inMemorySampleContainer())
}

#endif // DEBUG
