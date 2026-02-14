//
//  LandmarkDetailsView.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/7/26.
//

import SwiftUI
import MapKit

/// Displays the details of the given landmark, including notes, address, and a lookaround preview.
struct LandmarkDetailsView: View {

    /// The landmark to dislpay
    let landmark: Landmark

    // UI state
    @Environment(\.dismiss) private var dismiss
    @State private var isEditorShowing: Bool = false

    // Segmented picker
    private enum Section: String, CaseIterable, Identifiable {
        case details = "Details"
        case preview = "Preview"        
        var id: Self { self }
    }
    @State private var selectedSection: Section = .details
    
    // Location preview
    @State private var lookaroundScene: MKLookAroundScene? = nil
    @State private var lopokaroundError: Error? = nil

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
                        // TODO patmcg handle loading state
                        // TODO patmcg test error state, which may legit just mean
                        //      lookaround is not available there.  So handle it
                        //      like as "not available" more than an "error" per se.
                        if let lookaroundScene = self.lookaroundScene {
                            LookAroundPreview(initialScene: lookaroundScene)
                                .padding()
                        } else if let lookaroundError = self.lopokaroundError {
                            Text(lookaroundError.localizedDescription)
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
                        self.isEditorShowing = true
                    }
                }
            }
        }
        .sheet(isPresented: self.$isEditorShowing) {
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
        // TODO patmcg consider moving this to a service
        // TODO patmcg show placeholder if lookaround won't load
        if self.lookaroundScene == nil {
            let lookaroundRequest = MKLookAroundSceneRequest(coordinate: self.landmark.location)
            lookaroundRequest.getSceneWithCompletionHandler { (scene, error) in
                if let sceneToShow = scene {
                    DispatchQueue.main.async {
                        self.lookaroundScene = sceneToShow
                    }
                } else if let errorToShow = error {
                    self.lopokaroundError = errorToShow
                }
            }
        }
    }
}

#Preview {
    LandmarkDetailsView(landmark: LandmarkSampleData().capital)
}
