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
    
    /// The landmark to display
    let landmark: Landmark

    // Environment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.lookAroundService) var lookAroundService

    // UI state
    @State private var isEditorShowing: Bool = false

    // Segmented picker
    private enum Section: String, CaseIterable, Identifiable {
        case details = "Details"
        case preview = "Preview"        
        var id: Self { self }
    }
    @State private var selectedSection: Section = .details
    
    // Look-around location preview
    private enum LookAroundState {
        case initial
        case resolved(MKLookAroundScene)
        case notAvailable
        case failure(Error)
    }
    @State private var lookAroundState: LookAroundState = .initial

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
                        detailsView
                    case .preview:
                        lookAroundView
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
                            isEditorShowing = true
                        }
                    }
                }
        }
        .sheet(isPresented: $isEditorShowing) {
            NavigationStack {
                LandmarkForm(mode: .edit(landmark))
            }
        }
        .task {
            do {
                // Fetch the look-around scene when the view loads
                if let lookAroundScene = try await lookAroundService.lookAroundScene(
                    for: landmark.location) {
                    lookAroundState = .resolved(lookAroundScene)
                } else {
                    lookAroundState = .notAvailable
                }
            } catch {
                lookAroundState = .failure(error)
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var detailsView: some View {
        Text(landmark.notes)
            .padding()
        Text(landmark.formattedAddress)
            .font(.footnote)
            .padding(.leading)
    }
    
    @ViewBuilder
    private var lookAroundView: some View {
        switch lookAroundState {
            case .initial:
            EmptyView()
        case .resolved(let scene):
            LookAroundPreview(initialScene: scene)
                .padding()
        case .notAvailable:
            // TODO patmcg improve this view
            Text("Nothing to see here")
        case .failure(let error):
            ErrorView(shortMessage: "Look-around issues", error: error)
        }
    }
    
}

#Preview("Real look-around)") {
    LandmarkDetailsView(landmark: LandmarkSampleData().capital)
        .environment(\.lookAroundService, MapKitLookAroundService())
}

#Preview("Mock look-around") {
    LandmarkDetailsView(landmark: LandmarkSampleData().capital)
}
