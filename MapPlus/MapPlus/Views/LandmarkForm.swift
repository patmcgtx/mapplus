//
//  LandmarkForm.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/27/26.
//

import SwiftUI
import SwiftData
import MCEmojiPicker

/// A  view for creating or editing landmarks.
struct LandmarkForm: View {
    
    /// Creates a form to create or edit a landmark
    init(mode: LandmarkFormViewModel.Mode) {
        self.viewModel = LandmarkFormViewModel(mode: mode)
        self.landmarkInEdit = viewModel.landmarkToEdit
    }

    // Environment
    @Environment(\.locationService) private var locationService
    @Environment(\.addressLookupService) private var addressLookupService
    
    // The view model owns the form mode and configuration
    private let viewModel: LandmarkFormViewModel
    
    // The landmark being edited: either a brand new one or one loaded in
    @State private var landmarkInEdit: Landmark
        
    // Environment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // Notes preview
    @State private var isNotesPreviewEnabled: Bool = false
    
    // Categories
    @Query(sort: \LandmarkCategory.name, order: .forward)
    private var allCategories: [LandmarkCategory]

    // Icon picker state
    @State private var isShowingEmojiPicker = false
//    @State private var selectedEmoji = "📍"
    
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
    
    // Field focus
    private enum FocusField: Hashable {
        case landmarkName
        case address
    }
    @FocusState private var focusField: FocusField?
    
    var body: some View {
        Form {
            saveError
            detailsSection
            notesSection
            categoriesSection
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
        .scrollDismissesKeyboard(ScrollDismissesKeyboardMode.immediately)
        .task(priority: .userInitiated) {
            switch viewModel.mode {
            case .create:
                // If we're editing a new landmark, _try_ to pre-populate the current location
                do {
                    let resolvedAddress = try await locationService.getCurrentLocation()
                    await MainActor.run {
                        addressSearchState = .searchResolved(resolvedAddress)
                    }
                } catch {
                    // Not a reportable error if this fails; just let them proceed as normal
                    break
                }
            case .edit:
                // When editing an existing landmark, pre-resolve the address
                // to the landmark's known location.
                addressSearchState = .searchResolved(
                    LocationInfo(
                        formattedDescription: landmarkInEdit.formattedAddress,
                        latitude: landmarkInEdit.location.latitude,
                        longitude: landmarkInEdit.location.longitude
                    )
                )
            }
        }
        .onAppear {
            focusField = .landmarkName
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var categoriesSection: some View {
        Section("Categories") {
            HStack {
                // A flow layout of categories in edit mode
                CategoryFlow(categories: $landmarkInEdit.categories, mode: .edit)

                Spacer()
                
                // A menu of possible categories to add to the landmark
                Menu {
                    ForEach(unassignedCategories, id: \.id) { category in
                        Button(category.name) {
                            withAnimation(.bouncy) {
                                landmarkInEdit.categories = landmarkInEdit.addAndSort(category: category)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "plus.circle")
                }
            }
        }
    }
    
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
            HStack(alignment: .lastTextBaseline) {
                
                // Landmark name input
                TextField("name".localized, text: $landmarkInEdit.name,
                          onEditingChanged: { _ in
                })
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled(false)
                .focused($focusField, equals: .landmarkName)
                
                // Landmark name clear button
                Button {
                    landmarkInEdit.name = ""
                    focusField = .landmarkName
                } label: {
                    Image(systemName: "xmark.circle")
                }
            }
            
            // Emoji selector
            Button {
                hideKeyboard()
                isShowingEmojiPicker = true
            } label: {
                HStack {
                    Text(landmarkInEdit.emoji)
                    Text("emoji-selector".localized)
                }
            }
            .emojiPicker(isPresented: $isShowingEmojiPicker, selectedEmoji: $landmarkInEdit.emoji)
            .padding(8)
            .onChange(of: landmarkInEdit.emoji, initial: false) {
                isShowingEmojiPicker = false
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
                MarkdownPreview(markdown: landmarkInEdit.notes)
            } else {
                TextEditor(text: $landmarkInEdit.notes)
                    .textInputAutocapitalization(.sentences)
                    .autocorrectionDisabled(false)
            }
        }
    }    
        
    @ViewBuilder
    private var markdownNote: some View {
        HStack {
            MarkdownUsageNote()
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
                .submitLabel(.search)
                .textInputAutocapitalization(.none)
                .autocorrectionDisabled(false)
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
            // TODO patmcg this rolls back the persistent state but not the in-memory Landmark
            modelContext.rollback() // Rollback any unsaved changed to the landmark
            dismiss()
        }
    }
    
    private var saveButton: some View {
        Button("save".localized) {
            do {
                switch addressSearchState {
                case .searchInitial, .searching, .searchFailed:
                    break
                case .searchResolved:
                    try viewModel.save(context: modelContext)
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
                        Text(landmarkInEdit.emoji)
                        Spacer()
                        Text(landmarkInEdit.name)
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
        
    /// Which categories have not been assigned to the landmake in edit
    private var unassignedCategories: [LandmarkCategory] {
        allCategories.filter {
            landmarkInEdit.categories.contains($0) == false
        }
    }

    private func runLocationSearch(ofType searchType: LocationSearchType) {
        Task {
            do {
                await MainActor.run {
                    addressSearchState = .searching
                }
                let resolvedAddress: LocationInfo
                switch searchType {
                case .textSearch(let searchString):
                    // TODO patmcg consider using a Binding
                    resolvedAddress = try await addressLookupService.lookup(address: searchString)
                case .currentLocation:
                    // TODO patmcg consider using a Binding
                    resolvedAddress = try await locationService.getCurrentLocation()
                }
                await MainActor.run {
                    addressSearchState = .searchResolved(resolvedAddress)
                    locationSearchInput = resolvedAddress.formattedDescription
                    landmarkInEdit.formattedAddress = resolvedAddress.formattedDescription
                    landmarkInEdit.latitude = resolvedAddress.coordinates.latitude
                    landmarkInEdit.longitude = resolvedAddress.coordinates.longitude
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
            return landmarkInEdit.name.isPopulated
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
        SampleLandmarks().capital)
    )
}

