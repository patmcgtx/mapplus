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

    @Environment(\.lookAroundService) var lookAroundService
    
    /// The landmark to dislpay
    let landmark: Landmark

    // Environment
    @Environment(\.dismiss) private var dismiss

    // UI state
    @State private var isEditorShowing: Bool = false

    // Segmented picker
    private enum Section: String, CaseIterable, Identifiable {
        case details = "Details"
        case preview = "Preview"        
        var id: Self { self }
    }
    @State private var selectedSection: Section = .details
    
    // Location preview
    @State private var lookAroundScene: MKLookAroundScene? = nil
    @State private var lookAroundError: Error? = nil

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
                        if let scene = self.lookAroundScene {
                            LookAroundPreview(initialScene: scene)
                                .padding()
                        } else {
                            // TODO patmcg
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
        .task {
            do {
                lookAroundScene = try await lookAroundService.lookAroundScene(for: self.landmark.location)
            } catch {
                lookAroundError = error
            }

        }
    }
    
    // MARK: - Private helpers
    
//    func fetchLookaroundScene() {
//        // TODO patmcg consider moving this to a service
//        // TODO patmcg show placeholder if lookaround won't load
//        if self.lookaroundScene == nil {
//            let lookaroundRequest = MKLookAroundSceneRequest(coordinate: self.landmark.location)
//            lookaroundRequest.getSceneWithCompletionHandler { (scene, error) in
//                if let sceneToShow = scene {
//                    DispatchQueue.main.async {
//                        self.lookaroundScene = sceneToShow
//                    }
//                } else if let errorToShow = error {
//                    self.lopokaroundError = errorToShow
//                }
//            }
//        }
//    }
}

#Preview {
    LandmarkDetailsView(landmark: LandmarkSampleData().capital)
}
