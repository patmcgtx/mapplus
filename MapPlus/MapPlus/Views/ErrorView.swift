//
//  ErrorView.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/13/26.
//

import SwiftUI

/// A view that presents an error, displayed with an ironic retro look.
struct ErrorView: View {
    
    /// A contextual message to display to the user
    let message: String
    
    /// The root error, which may be displayed for debugging purposes
    let error: Error
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "exclamationmark.circle")
                Text(message)
            }
            Text("")
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

#Preview {
    ErrorView(
        message: "No address found",
        error: MapPlusError.noAddressFound
    )
}
