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
    
    let iconsToShow: [SFSymbol]

    var body: some View {
        SymbolsPicker(
            selection: $landmarkIconName,
            title: "Pick icon",
            autoDismiss: true,
            symbols: self.iconsToShow,
            closeButton: {
                // TODO patmcg would be nice to find a way to hide this completely
            }
        )
    }
}

private struct IconPickerPreview: View {

    let iconsToShow: [SFSymbol]

    @State private var iconName: String = "mappin"

    var body: some View {
        IconPicker(landmarkIconName: $iconName, iconsToShow: self.iconsToShow)
    }
}

#Preview("All icons") {
    IconPickerPreview(iconsToShow: [])
}

#Preview("Walking icons") {
    IconPickerPreview(iconsToShow:
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
