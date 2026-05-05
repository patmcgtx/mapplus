//
//  AppSettings.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 5/2/26.
//
import SwiftData

// TODO patmcg next steps:
// - Add a AppSettingsStoring / AppSettingsStore pattern?  Is it needed?
// - At least provide an easy way to get the one instance and query and update this thing.
// - Update it in CategoriesSelection flow with a "match any" / "match all" toggle.
// - Query it in MainMapView to switch between filteredLandmarksOr / filteredLandmarksAnd

/// Storage model for persistent app settings.
///
/// We could be using `@AppStorage` instead, but I'm trying SwiftData for these reasons:
/// * Some of the user state such as `LandmarkCategory.isSelected` are saved in SwiftData,
///     so saving any related state the same way provides consistency.  For example, the category selection
///     type interacts with `LandmarkCategory.isSelected`, so I want to keep them in the same place
///     to prevent bugs.
/// * Putting these settings in SwiftData will (potentially) allow cross-device sync of state via iCloud.
/// * It goes with my "all in on SwiftData for app state" approach / experiment.
@Model
class MapsPlusSettings {    
    
    /// The current state of category selection.
    var categorySelectionType = CategorySelectionType.matchingAny
    
    /// Creates a new instance of AppSettings
    init() {
        //
    }
}
