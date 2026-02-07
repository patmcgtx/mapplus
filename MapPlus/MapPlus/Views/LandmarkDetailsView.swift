//
//  LandmarkDetailsView.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/7/26.
//

import SwiftUI

struct LandmarkDetailsView: View {
    
    let landmark: Landmark
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: landmark.systemImageName)
                Text(landmark.name)
            }
            Text(landmark.notes)
        }
    }
}

#Preview {
    LandmarkDetailsView(
        // TODO patmcg add a "sample landmark" method somewhere, or like SampleLandmarks().mozarts, etc.
        landmark: Landmark(
            name: "Mozart's",
            notes: "Great coffee on the lake",
            formattedAddress: "",
            systemImageName: "arcade.stick",
            location: LandmarkSampleData().sampleData.first!.location
        )
    )
}
