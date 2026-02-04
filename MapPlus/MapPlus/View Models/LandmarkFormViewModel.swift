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

    // TODO initialize this with a mode
//    let mode: Mode
    
    // TODO patmcg doc
    func title(for mode: Mode) -> String {
        // TODO patmcg localize
        switch mode {
        case .create: return "New Landmark"
        case .edit(let landmark): return landmark.name
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
