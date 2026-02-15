//
//  LandmarkFormViewModel.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//

import SFSafeSymbols

// TODO patmcg take a fresh look at this overall

/// View model that provides display data for `LandmarkFormView`.
///
/// This type encapsulates the state needed to present and edit a landmark in the form,
/// including the current mode (creating a new landmark or editing an existing one),
/// derived titles, default values, and the curated list of SF Symbols that the
/// icon picker should display.
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

    /// The title to display at the top of the form.
    ///
    /// - Returns: "New Landmark" when creating, or the existing landmark's name when editing.
    var formTitle: String {
        switch mode {
        case .create:
            return String(localized: "New Landmark")
        case .edit(let landmark):
            return landmark.name
        }
    }
    
    /// The landmark being edited, if the form is in edit mode; otherwise `nil`.
    var landmarkToEdit: Landmark? {
        switch self.mode {
        case .create:
            return nil
        case .edit(let landmark):
            return landmark
        }
    }
    
    /// The initial value for the name field, empty when creating.
    var landmarkName: String {
        self.landmarkToEdit?.name ?? ""
    }
    
    /// The initial SF Symbol name for the icon field, defaults to `"mappin.circle"` when creating.
    var landmarkIconName: String {
        self.landmarkToEdit?.systemImageName ?? "mappin.circle"
    }

    /// Curated set of SF Symbols to present in the icon selector.
    ///
    /// The list is intentionally limited to map-appropriate and commonly recognizable
    /// symbols to keep the picker focused and fast. The order controls presentation.
    ///
    /// - Important: Avoid duplicates; duplicates can cause UI selection issues.
    /// - FIXME: Add unit tests to validate representative entries, total count, and uniqueness.
    let iconsToShow: [SFSymbol] = [
        .mappin,
        .mappinAndEllipse,
        .mapCircle,
        .mappinSquare,
        .house,
        .musicNoteHouse,
        .houseBadgeWifi,
        .building,
        .building2,
        .building2CropCircle,
        .dollarsignBankBuilding,
        .forkKnife,
        .forkKnifeCircle,
        .cupAndSaucer,
        .cupAndHeatWaves,
        .mug,
        .graduationcap,
        .arcadeStick,
        .arcadeStickConsole,
        .bus,
        .tram,
        .ferry,
        .cablecar,
        .bicycle,
        .car,
        .fuelpump,
        .person,
        .person2,
        .person3,
        .figure,
        .figureWalk,
        .figureWave,
        .figureStand,
        .figureStandDress,
        .figureAndChildHoldinghands,
        .figure2AndChildHoldinghands,
        .figurePlay,
        .figureRun,
        .figureRoll,
        .figureYoga,
        .figureDance,
        .figureKickboxing,
        .figureMindAndBody,
        .figureSkateboarding,
        .figureOpenWaterSwim,
    ]

}
