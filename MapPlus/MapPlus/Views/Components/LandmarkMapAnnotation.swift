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
 
    /// The landmark to display
    let landmark: Landmark
 
    // TODO get emoji from the landmark landmark itself
    private var randomEmoji: String {
        ["🤦🏻‍♂️", "👍", "➕", "🐢", "💰"].randomElement() ?? "🤦🏻‍♂️"
    }

    var body: some View {
            Text(randomEmoji)
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
        LandmarkMapAnnotation(landmark: SampleLandmarks().brooklynBridge)
        LandmarkMapAnnotation(landmark: SampleLandmarks().capital)
        LandmarkMapAnnotation(landmark: SampleLandmarks().charingCross)
    }
    .padding(40)
    .background(.green).cornerRadius(10)
}
