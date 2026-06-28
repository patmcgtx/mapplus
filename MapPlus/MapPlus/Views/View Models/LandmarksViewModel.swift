//
//  LandmarksViewModel.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 6/28/26.
//

import Foundation
import SwiftData

/// View model that provides state and logic for `LandmarksView`.
@Observable @MainActor
class LandmarksViewModel {

    // MARK: UI State

    /// Triggers showing the new-landmark flow
    var showLandmarkForm: Bool = false
    
    /// The landmark we're editing, if any.
    var landmarkToEdit: Landmark? = nil
    
    /// Set when a landmark is deleted.
    var didDeleteLandmark: Bool = false
    
    /// Any deletion errors encountered.
    var deleteError: Error?

    // MARK: Actions

    /// Deletes the landmarks at the given indices.
    /// Sets `deleteError` if there is an error commiting the deletion.
    /// - Parameter offsets: The indices of the landmarks to delete.
    /// - Parameter landmarks: The array of landmarks to delete from
    /// - Parameter modelContext: The persistent context to delete from
    func deleteLandmarks(
        at offsets: IndexSet,
        in landmarks: [Landmark],
        modelContext: ModelContext
    ) {
        let store = LandmarkStore(modelContext: modelContext)
        do {
            for index in offsets {
                try store.delete(landmark: landmarks[index])
            }
        } catch {
            deleteError = error
        }
        didDeleteLandmark.toggle()
    }
}
