//
//  IconPicker.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/28/26.
//

import SwiftUI
import SFSafeSymbols
import SFSymbolsPicker

struct IconPicker: View {
        
    @Binding var landmarkIconName: String
    
    let symbolsToShow: [SFSymbol]

    var body: some View {
        SymbolsPicker(
            selection: $landmarkIconName,
            title: "Pick icon",
            autoDismiss: true,
            symbols: self.symbolsToShow,
            closeButton: {
                // TODO patmcg would be nice to find a way to hide this completely
            }
        )
    }
}

private struct IconPickerPreview: View {

    let symbolsToShow: [SFSymbol]

    @State private var iconName: String = "mappin"

    var body: some View {
        IconPicker(landmarkIconName: $iconName, symbolsToShow: self.symbolsToShow)
    }
}

#Preview("All icons") {
    IconPickerPreview(symbolsToShow: [])
}

#Preview("Walking icons") {
    IconPickerPreview(symbolsToShow:
    [
        .figureWalk,
        .figureWalkCircle,
        .figureWalkCircleFill,
        .figureWave,
        .figureWaveCircle,
        .figureWaveCircleFill,
    ]
    )
}
