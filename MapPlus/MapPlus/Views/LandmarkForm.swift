//
//  LandmarkForm.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/27/26.
//

import SwiftUI
import SFSafeSymbols

/// A  view for creating or editing landmarks.
struct LandmarkForm: View {
    
    /// Creates a form to create or edit a landmark
    init(mode: LandmarkFormViewModel.Mode) {
        self.viewModel = LandmarkFormViewModel(mode: mode)
    }

    // Environment
    @Environment(\.locationService) private var locationService
    @Environment(\.addressLookupService) private var addressLookupService
    
    // The view model owns the form mode and configuration
    private let viewModel: LandmarkFormViewModel
        
    // Environment
    @Environment(\.dismiss) private var dismiss
    
    // Persistence
    @Environment(\.modelContext) private var modelContext
    private var storageService: LandmarkStorageService {
        LandmarkStorageService(modelContext: modelContext)
    }
    
    // Form input
    @State private var landmarkNameInput: String = ""
    @State private var landmarkIconNameSelected: String = "mappin.circle"
    @State private var landmarkNotesInput: String = ""
    @State private var isNotesPreviewEnabled: Bool = false
    
    // Computed height for notes TextEditor
    private var notesEditorHeight: CGFloat {
        let lineHeight: CGFloat = 20
        let padding: CGFloat = 16
        let minHeight: CGFloat = 100
        
        // Calculate approximate number of lines
        let lineCount = max(landmarkNotesInput.components(separatedBy: .newlines).count, 5)
        return max(minHeight, CGFloat(lineCount) * lineHeight + padding)
    }

    // Icon picker state
    @State private var isShowingIconPicker: Bool = false
    
    // Save state
    private enum SaveState {
        case saveInitial
        case saved
        case saveFailed(Error)
    }
    
    @State private var saveState: SaveState = .saveInitial
    
    // Location search
    private enum LocationSearchType {
        case textSearch(String)
        case currentLocation
    }
    
    @State private var locationSearchInput: String = ""

    // Location search state
    private enum AddressSearchState {
        case searchInitial
        case searching
        case searchResolved(LocationInfo)
        case searchFailed(Error)
    }
    
    @State private var addressSearchState: AddressSearchState = .searchInitial
    
    var body: some View {
        Form {
            saveError
            detailsSection
            notesSection
            if case .create = viewModel.mode {
                locationSearchSection
            }
            previewSection
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                cancelButton
            }
            ToolbarItem(placement: .confirmationAction) {
                saveButton
            }
        }
        .toolbarTitleDisplayMode(.inline)
        .navigationTitle(viewModel.formTitle)
        .sheet(isPresented: $isShowingIconPicker) {
            IconPicker(
                symbolOptions: viewModel.iconsToShow,
                selectedSymbolName: $landmarkIconNameSelected
            )
        }
        .scrollDismissesKeyboard(ScrollDismissesKeyboardMode.immediately)
        .onAppear() {
            switch viewModel.mode {
            case .create:
                break
            case .edit(let landmark):
                // Populate inputs with existing landmark info
                landmarkNameInput = landmark.name
                landmarkIconNameSelected = landmark.systemImageName
                landmarkNotesInput = landmark.notes
                addressSearchState = .searchResolved(
                    LocationInfo(
                        formattedDescription: landmark.formattedAddress,
                        latitude: landmark.location.latitude,
                        longitude: landmark.location.longitude
                    )
                )
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var saveError: some View {
        switch saveState {
        case .saveInitial, .saved:
            EmptyView()
        case .saveFailed(let error):
            ErrorView(shortMessage: "failed-to-save".localized, error: error)
        }
    }
    
    private var detailsSection: some View {
        Section("details".localized) {
            HStack {
                TextField("name".localized, text: $landmarkNameInput,
                          onEditingChanged: { _ in
                })
                .autocorrectionDisabled()
                Button {
                    landmarkNameInput = ""
                } label: {
                    Image(systemName: "xmark.circle")
                }
            }
            Button {
                isShowingIconPicker = true
            } label: {
                Label("icon".localized, systemImage: landmarkIconNameSelected)
            }
        }
    }
    
    @ViewBuilder
    private var notesSection: some View {
        Section(
            header: Text("notes".localized),
            footer: markdownNote
        ) {
            if isNotesPreviewEnabled {
                if let markdown = landmarkNotesInput.withMarkdown {
                    Text(markdown)
                } else {
                    Text(landmarkNotesInput)
                }
            } else {
                TextEditor(text: $landmarkNotesInput)
                    .frame(height: notesEditorHeight)
                    .animation(.easeInOut(duration: 0.2), value: notesEditorHeight)
            }
        }
    }    
        
    @ViewBuilder
    private var markdownNote: some View {
        HStack {
            MarkdownNote()
            Spacer()
            Toggle("show-me", systemImage: "eye",
                   isOn: $isNotesPreviewEnabled)
                .toggleStyle(.button)
                .font(.footnote)
        }
    }
    
    private var locationSearchSection: some View {
        Section("location".localized) {
            HStack {
                TextField(
                    "addr-or-location-name".localized,
                    text: $locationSearchInput)
                .autocorrectionDisabled()
                Button {
                    runLocationSearch(ofType: .textSearch(locationSearchInput))
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                Button {
                    runLocationSearch(ofType: .currentLocation)
                } label: {
                    Image(systemName: "location")
                }
            }
        }
    }
    
    private var cancelButton: some View {
        Button("cancel".localized, systemImage: "xmark") {
            dismiss()
        }
    }
    
    private var saveButton: some View {
        Button("save".localized) {
            do {
                switch addressSearchState {
                case .searchInitial, .searching, .searchFailed:
                    break
                case .searchResolved(let addressInfo):
                    try storageService.save(
                        location: addressInfo,
                        name: landmarkNameInput,
                        notes: landmarkNotesInput,
                        iconName: landmarkIconNameSelected
                    )
                    saveState = .saved
                }
                dismiss()
            } catch {
                saveState = .saveFailed(error)
            }
        }
        .disabled(!isSaveEnabled)
    }
    
    @ViewBuilder
    private var previewSection: some View {
        Section("preview".localized) {
            HStack {
                HStack {
                    
                    // Landmark icon
                    VStack {
                        Spacer()
                        Image(systemName: landmarkIconNameSelected)
                        Spacer()
                        Text(landmarkNameInput)
                        Spacer()
                    }
                    .multilineTextAlignment(.center)
                    .padding()
                    Spacer()
                    
                    // Landmark description
                    switch addressSearchState {
                    case .searchInitial:
                        EmptyView()
                    case .searching:
                        ProgressView()
                    case .searchResolved(let addressInfo):
                        Text(addressInfo.formattedDescription)
                    case .searchFailed(let error):
                        ErrorView(shortMessage: "location-search-failed".localized, error: error)
                    }
                }
            }
        }
    }
    
    
    // MARK: - Internal helpers
    
    private func runLocationSearch(ofType searchType: LocationSearchType) {
        Task {
            do {
                await MainActor.run {
                    addressSearchState = .searching
                }
                let resolvedAddress: LocationInfo
                switch searchType {
                case .textSearch(let searchString):
                    resolvedAddress = try await addressLookupService.lookup(address: searchString)
                case .currentLocation:
                    resolvedAddress = try await locationService.getCurrentLocation()
                }
                await MainActor.run {
                    addressSearchState = .searchResolved(resolvedAddress)
                }
            } catch {
                await MainActor.run {
                    addressSearchState = .searchFailed(error)
                }
            }
        }
    }
    
    private var isSaveEnabled: Bool {
        switch addressSearchState {
        case .searchInitial, .searching, .searchFailed:
            return false
        case .searchResolved:
            return landmarkNameInput.isPopulated
        }
    }
    
}

// MARK: - Previews

#Preview("Create - mock services") {
    LandmarkForm(mode: .create)
        .environment(\.locationService, MockLocationService())
        .environment(\.addressLookupService, MockAddressLookupService())
}

#Preview("Create - real services") {
    LandmarkForm(mode: .create)
}

#Preview("Edit - real") {
    LandmarkForm(mode: .edit(
        LandmarkSampleData().capital)
    )
}

