//
//  ErrorView.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/13/26.
//

import SwiftUI

/// A view that presents an error (displayed with an ironic retro look).
struct ErrorView: View {
    
    /// A contextual message to display to the user
    let shortMessage: String
    
    /// The root error, which may be displayed for debugging purposes
    let error: Error
    
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "exclamationmark.circle")
                Text(shortMessage)
            }
            Text("")
            // TODO patmcg move the details into a "wut?" button with a sheet that says, "This may make zero sense, but your device is telling me..."
            Text(error.localizedDescription)
                .font(.footnote)
        }
        .fontDesign(.monospaced)
        .foregroundStyle(errorColor)
        .padding()
        .border(errorColor)
        .cornerRadius(15.0)
    }

    /// A red that meets WCAG AA contrast (≥4.5:1) against the default background in both light and dark mode.
    private var errorColor: Color {
        colorScheme == .dark ? .red : Color(red: 179/255, green: 0, blue: 0)
    }
}

// MARK: - Previews

#Preview {
    ErrorView(
        shortMessage: "No address found",
        error: MapPlusError.noAddressFound
    )
}
