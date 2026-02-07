//
//  LandmarkDetailsView.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/7/26.
//

import SwiftUI

struct LandmarkDetailsView: View {

    let landmark: Landmark

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        // TODO patmcg an edit button would be nice too
        NavigationStack {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: landmark.systemImageName)
                        Text(landmark.name)
                            .font(.title)
                    }
                    .padding()
                    Text(landmark.notes)
                        .padding(.leading)
                    Spacer()
                }
                .padding()
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "x.circle") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button("Edit", systemImage: "square.and.pencil") {
                        LandmarkForm(mode: .edit(landmark))
                    }
                }
            }
        }
    }
}

#Preview {
    LandmarkDetailsView(
        // TODO patmcg add a "sample landmark" method somewhere, or like SampleLandmarks().mozarts, etc.
        // or a method with default params
        landmark: Landmark(
            name: "Mozart's on Lake Austin",
            notes: "Great coffee on the lake and also great pastries!",
            formattedAddress: "",
            systemImageName: "arcade.stick",
            location: LandmarkSampleData().sampleData.first!.location
        )
    )
}
