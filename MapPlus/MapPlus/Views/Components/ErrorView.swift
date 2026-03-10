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
        .foregroundStyle(Color.red)
        .padding()
        .border(Color.red)
        .cornerRadius(15.0)
    }
}

// MARK: - Previews

#Preview {
    ErrorView(
        shortMessage: "No address found",
        error: MapPlusError.noAddressFound
    )
}
