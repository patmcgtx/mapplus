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

    var showLandmarkForm: Bool = false
    var landmarkToEdit: Landmark? = nil
    var didDeleteLandmark: Bool = false

    // MARK: Actions

    func deleteLandmarks(at offsets: IndexSet, in landmarks: [Landmark], modelContext: ModelContext) {
        let store = LandmarkStore(modelContext: modelContext)
        for index in offsets {
            try? store.delete(landmark: landmarks[index])
        }
        didDeleteLandmark.toggle()
    }
}
