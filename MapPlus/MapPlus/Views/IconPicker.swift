//
//  IconPicker.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/28/26.
//

import SwiftUI
import SFSymbolsPicker

struct IconPicker: View {
    
    @Binding var landmarkIconName: String
    
    var body: some View {
        SymbolsPicker(
            selection: $landmarkIconName,
            title: "Pick icon",
            autoDismiss: true,
            symbols: [
                .figureWalk,
                .figureWalkCircle,
                .figureWalkCircleFill,
                .figureWave,
                .figureWaveCircle,
                .figureWaveCircleFill,
            ],
            closeButton: {
                // TODO patmcg would be nice to find a way to hide this completely
            }
        )
    }
}

private struct IconPickerPreview: View {
    @State private var iconName: String = "mappin"

    var body: some View {
        IconPicker(landmarkIconName: $iconName)
    }
}

#Preview {
    IconPickerPreview()
}
