//
//  LandmarksView.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/25/26.
//

import SwiftUI

struct LandmarksView : View {

    @Environment(\.dismiss) var dismiss

    let landmarks: [Landmark]
    
    var body: some View {
        NavigationStack {
            List(landmarks, id: \.id) { landmark in
                HStack {
                    Label(landmark.name, systemImage: landmark.systemImageName)
                }
            }
            .navigationTitle("Landmarks")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    LandmarksView(landmarks: LandmarkSampleData().sampleData)
}
