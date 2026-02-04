//
//  LandmarkFormViewModel.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//

import SFSafeSymbols

/// View model supplying data LandmarkFormView
struct LandmarkFormViewModel {

    // TODO patmcg doc
    enum Mode {
        case create
        case edit(Landmark)
    }

    /// The current mode for the form
    let mode: Mode

    /// Initialize the view model with a mode
    init(mode: Mode) {
        self.mode = mode
    }

    /// Title to show for the given mode
    var title: String {
        // TODO patmcg localize
        switch mode {
        case .create:
            return "New Landmark"
        case .edit(let landmark):
            return landmark.name
        }
    }
    
    // TODO patmcg add unit tests
    //      - Check some entries
    //      - Check count
    //      - Make sure there are no dups (causes UI issues)

    /// Which icons to show in the icon selector
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
