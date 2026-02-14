//
//  IconPicker.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/28/26.
//

import SwiftUI
import SFSafeSymbols
import SFSymbolsPicker

/// A view that lets the user pic an icon a set up SF Symbols, as specified by `iconsToShow` or defaulting to all symbols,
/// and then populating the provided binding.
struct IconPicker: View {
        
    // TODO patmcg rename to something non-landmark-specific
    /// Binding to capture the user-selected SF symbol name
    @Binding var selectedSymbolName: String
    
    /// Which SF Symbols for the user to pick from, or all SF Symbols if this is let empty.
    let symbolOptions: [SFSymbol]
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            SymbolsPicker(
                selection: $selectedSymbolName,
                title: "Pick icon",
                autoDismiss: true,
                symbols: self.symbolOptions,
                closeButton: {
                    // Provide empty view to hide the built-in close button
                    EmptyView()
                }
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "x.circle") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Previews

private struct IconPickerPreview: View {

    let iconsToShow: [SFSymbol]

    @State private var iconName: String = "mappin"

    var body: some View {
        IconPicker(
            selectedSymbolName: $iconName,
            symbolOptions: self.iconsToShow
        )
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
