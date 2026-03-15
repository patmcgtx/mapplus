//
//  LandmarkMapAnnotation.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/14/26.
//
import SwiftUI
import MapKit

/// A view of an individual landmark placed on the map.
/// The map itself will display the landmark name; this is just the visual to go with it.
struct LandmarkMapAnnotation: View {
 
    /// The landmark's emoji to display
    let emoji: Character
 
    var body: some View {
            Text(String(emoji))
                .font(.headline)
                .padding(10)
                .background(
                    Circle()
                        .fill(Color.white)
                        .strokeBorder(.primary, lineWidth: 2)
                        .opacity(0.67)
                )
    }
}

#Preview {
    VStack {
        LandmarkMapAnnotation(emoji: Character("📍"))
        LandmarkMapAnnotation(emoji: Character("🇺🇸"))
        LandmarkMapAnnotation(emoji: Character("🐢"))
    }
    .padding(40)
    .background(.green).cornerRadius(10)
}
