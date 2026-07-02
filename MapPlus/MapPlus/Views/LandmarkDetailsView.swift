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
    
    // MARK: Environment
    
    @Environment(\.dismiss)
    private var dismiss
    
    @Environment(\.lookAroundService)
    var lookAroundService: LookAroundService!
    
    // MARK: View state
    
    @State
    private var isEditorShowing: Bool = false

    @State
    private var viewModel: LandmarkDetailsViewModel

    private enum Section: String, CaseIterable, Identifiable {
        case details = "details"
        case preview = "preview"
        var id: Self { self }
        
        var localizedString: String {
            self.rawValue.localized
        }
    }
    @State private var selectedSection: Section = .details

    init(landmark: Landmark) {
        _viewModel = State(initialValue: LandmarkDetailsViewModel(landmark: landmark))
    }
    
    var body: some View {
        NavigationStack {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text(viewModel.landmark.symbol)
                        Text(viewModel.landmark.name)
                    }
                    .font(.title)
                    .padding()
                    
                    CategoriesViewFlow(categories: viewModel.landmark.categoriesSorted)
                    
                    Picker("section".localized, selection:$selectedSection) {
                        ForEach(Section.allCases) { section in
                            Text(section.localizedString)
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
                    Button("close".localized, systemImage: "x.circle") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button("edit".localized, systemImage: "square.and.pencil") {
                        isEditorShowing = true
                    }
                }
            }
        }
        .sheet(isPresented: $isEditorShowing) {
            NavigationStack {
                LandmarkForm(mode: .edit(viewModel.landmark))
            }
        }
        .task {
            await viewModel.loadLookAround(using: lookAroundService)
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var detailsView: some View {
        if let markdown = viewModel.landmark.notes.withMarkdown {
            Text(markdown)
                .padding()
        } else {
            Text(viewModel.landmark.notes)
                .padding()
        }
        HStack(alignment: .top) {
            Text(viewModel.landmark.formattedAddress)
                .font(.footnote)
                .padding(.leading)
            Spacer()
            VStack(alignment: .leading) {
                Button("get-directions", systemImage: "arrow.trianglehead.turn.up.right.circle") {
                    viewModel.landmark.openInMaps(
                        mapsOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault]
                    )
                }
                Button("show-in-maps", systemImage: "map") {
                    viewModel.landmark.openInMaps()
                }
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    private var lookAroundView: some View {
        switch viewModel.lookAroundState {
        case .initial:
            EmptyView()
        case .loading:
            ProgressView()
        case .resolved(let scene):
            LookAroundPreview(initialScene: scene)
                .padding()
        case .notAvailable:
            // Error states will be improved in #96
            Text("nothing-to-see".localized)
        case .failure(let error):
            // Error states will be improved in #96
            ErrorView(shortMessage: "look-around-issues".localized, error: error)
        }
    }
    
}

#if DEBUG

// MARK: - Previews

import SwiftData

#Preview("Real look-around") {
    LandmarkDetailsView(landmark: SampleLandmarks().brooklynBridge)
        .injectLiveServices()
}

#Preview("Mock - no look-around") {
    LandmarkDetailsView(landmark: SampleLandmarks().capital)
        .modelContainer(try! ModelContainer.inMemorySampleContainer())
        .injectMockServices()
        .environment(\.lookAroundService, MockLookAroundService(
            errorToThrow: nil,
            sceneToReturn: nil,
            networkDelaySeconds: 2.5
        ))
}

#Preview("Mock - look-around error") {
    LandmarkDetailsView(landmark: SampleLandmarks().charingCross)
        .environment(\.lookAroundService, MockLookAroundService(
            errorToThrow: MapPlusError.noLookAround,
            sceneToReturn: nil,
            networkDelaySeconds: 8.0
        ))
}

#endif // DEBUG
