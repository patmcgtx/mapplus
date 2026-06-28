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
    
    @Environment(\.modelContext)
    private var modelContext
    
    // MARK: Persistence
    
    @Query(sort: \Landmark.name, order: .forward)
    var landmarks: [Landmark]
    
    // MARK: View state
    
    @State
    private var viewModel = LandmarksViewModel()
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(landmarks) { landmark in
                    Button {
                        viewModel.landmarkToEdit = landmark
                    } label: {
                        HStack {
                            Text(landmark.symbol)
                            Text(landmark.name)
                        }
                    }
                }
                .onDelete { offsets in
                    viewModel.deleteLandmarks(at: offsets, in: landmarks, modelContext: modelContext)
                }
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.didDeleteLandmark)
            .navigationTitle("my-places".localized)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("dismiss".localized, systemImage: "xmark") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("add-place".localized, systemImage: "plus") {
                        viewModel.showLandmarkForm = true
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showLandmarkForm) {
            NavigationStack {
                LandmarkForm(mode: .create)
            }
        }
        .sheet(item: $viewModel.landmarkToEdit) { landmark in
            NavigationStack {
                LandmarkForm(mode: .edit(landmark))
            }
        }
    }
}

#if DEBUG

// MARK: - Previews

#Preview {
    LandmarksView()
        .modelContainer(try! ModelContainer.inMemorySampleContainer())
}

#endif // DEBUG
