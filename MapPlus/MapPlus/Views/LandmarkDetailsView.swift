//
//  LandmarkDetailsView.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/7/26.
//

import SwiftUI
import MapKit

// TODO patmcg doc
struct LandmarkDetailsView: View {

    let landmark: Landmark

    @Environment(\.dismiss) private var dismiss
    
    @State private var isEditing: Bool = false

    // Segmented picker
    private enum Section: String, CaseIterable, Identifiable {
        case details = "Details"
        case preview = "Preview"        
        var id: Self { self }
    }
    @State private var selectedSection: Section = .details
    
    // Location preview
    @State private var lookaroundScene: MKLookAroundScene?

    var body: some View {
        NavigationStack {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: landmark.systemImageName)
                        Text(landmark.name)
                            .font(.title)
                    }
                    .padding()
                    
                    Picker("Section", selection:$selectedSection) {
                        ForEach(Section.allCases) { section in
                            Text(section.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    switch selectedSection {
                    case .details:
                        Text(landmark.notes)
                            .padding()
                        Text(landmark.formattedAddress)
                            .font(.footnote)
                            .padding(.leading)
                    case .preview:
                        if let scene = self.lookaroundScene {
                            LookAroundPreview(initialScene: scene)
                                .padding()
                        }
                    }
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
                        self.isEditing = true
                    }
                }
            }
        }
        .sheet(isPresented: self.$isEditing) {
            NavigationStack {
                LandmarkForm(mode: .edit(landmark))
            }
        }
        .onAppear {
            self.fetchLookaroundScene()
        }
    }
    
    // MARK: - Private helpers
    
    func fetchLookaroundScene() {
        if self.lookaroundScene == nil {
            let lookaroundRequest = MKLookAroundSceneRequest(coordinate: self.landmark.location)
            lookaroundRequest.getSceneWithCompletionHandler { (scene, error) in
                if let sceneToShow = scene {
                    DispatchQueue.main.async {
                        self.lookaroundScene = sceneToShow
                    }
                } else if let errorToShow = error {
                    // TODO patmcg show error state
                }
            }
        }
    }
}

#Preview {
    LandmarkDetailsView(landmark: LandmarkSampleData().capital)
}
