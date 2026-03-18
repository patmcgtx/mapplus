//
//  LandmarkFormViewModel.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//
import SwiftData

// TODO patmcg unit test this VM and make sure it makes sense.
//      What is the SOLID-ness of this struct?

/// View model that provides for `LandmarkFormView`.
struct LandmarkFormViewModel {

    /// Indicates how the form is being used.
    /// - Note: In `create` mode, there is no backing landmark yet; in `edit` mode,
    ///         the provided `Landmark` supplies initial values.
    enum Mode {
        /// Create a brand new landmark.
        case create
        /// Edit an existing landmark.
        case edit(Landmark)
    }
    
    /// The current mode for the form
    let mode: Mode
    
    /// The landmark to edit in this form
    var landmarkToEdit: Landmark

    init(mode: Mode) {
        self.mode = mode
        switch self.mode {
        case .create:
            landmarkToEdit = Landmark()
        case .edit(let landmark):
            landmarkToEdit = landmark
        }
    }
    
    /// Saves any changes made to `landmarkToEdit`
    /// - Parameter context: The persistent context in which to save the landmark
    func save(context: ModelContext) throws {
        try LandmarkStore(modelContext: context)
            .commit(landmark: landmarkToEdit)
    }

    /// The landmark being edited, if the form is in edit mode; otherwise `nil`.
    private var sourceLandmark: Landmark? {
        switch self.mode {
        case .create:
            return nil
        case .edit(let landmark):
            return landmark
        }
    }

    /// The title to display at the top of the form.
    ///
    /// - Returns: "New Landmark" when creating, or the existing landmark's name when editing.
    var formTitle: String {
        switch mode {
        case .create:
            return "new-landmark".localized
        case .edit(let landmark):
            return landmark.name
        }
    }
        
    /// The initial value for the name field, empty when creating.
    var landmarkName: String {
        self.sourceLandmark?.name ?? ""
    }
    
    /// The initial emoji from the landmark or default
    var emoji: String {
        self.sourceLandmark?.emoji ?? ""
    }

}
