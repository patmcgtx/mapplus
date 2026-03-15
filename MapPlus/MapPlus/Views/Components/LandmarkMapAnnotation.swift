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
 
    // TODO get the emoji from the landmark itself
    let usFlag: Character = "\u{1F1FA}\u{1F1F8}"

    var body: some View {
            Text(String(usFlag))
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
