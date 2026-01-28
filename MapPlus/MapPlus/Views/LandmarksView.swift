//
//  LandmarksView.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/25/26.
//

import SwiftUI

struct LandmarksView : View {

    @Environment(\.dismiss) var dismiss
    
    @State private var showLandmarkForm: Bool = false

    let landmarks: [Landmark]
    
    var body: some View {
        NavigationStack {
            List(landmarks, id: \.id) { landmark in
                HStack {
                    Label(landmark.name, systemImage: landmark.systemImageName)
                }
            }
            .navigationTitle("My Places")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss", systemImage: "xmark") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Add a place", systemImage: "plus.circle") {
                        self.showLandmarkForm = true
                    }
                    .sheet(isPresented: $showLandmarkForm) {
                        LandmarkForm()
                    }
                }
            }
        }
    }
}

#Preview {
    LandmarksView(landmarks: LandmarkSampleData().sampleData)
}
