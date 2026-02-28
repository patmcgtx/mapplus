//
//  IconPickerViewModel.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/28/26.
//
import SFSafeSymbols

struct IconPickerViewModel {
    
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
