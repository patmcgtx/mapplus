//
//  IconPicker.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/28/26.
//

import SwiftUI
import SFSafeSymbols
import SFSymbolsPicker

/// A view that lets the user pick an icon from a set of SF Symbols
/// and then populating the provided binding.
struct IconPicker: View {
    
    private let viewModel = IconPickerViewModel()

    // Environment
    @Environment(\.dismiss) private var dismiss

    /// Binding to capture the user-selected SF symbol name
    @Binding var selectedSymbolName: String

    var body: some View {
        NavigationStack {
            SymbolsPicker(
                selection: $selectedSymbolName,
                title: "pick-icon".localized,
                autoDismiss: true,
                symbols: viewModel.iconsToShow,
                closeButton: {
                    // Provide empty view to hide the built-in close button
                    EmptyView()
                }
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("close".localized, systemImage: "x.circle") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Previews

private struct IconPickerPreview: View {

    @State private var iconName: String = "mappin"

    var body: some View {
        IconPicker(selectedSymbolName: $iconName)
    }
}

