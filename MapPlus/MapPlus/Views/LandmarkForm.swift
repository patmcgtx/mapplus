//
//  LandmarkForm.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/27/26.
//

import SwiftUI
import SwiftData

/// A  view for creating or editing landmarks.
struct LandmarkForm: View {
    
    /// Creates a form to create or edit a landmark
    init(mode: LandmarkFormViewModel.Mode) {
        self.viewModel = LandmarkFormViewModel(mode: mode)
    }

    // Environment
    @Environment(\.locationService) private var locationService
    @Environment(\.addressLookupService) private var addressLookupService
    
    // The view model owns the form mode, configuration, and location state
    @State private var viewModel: LandmarkFormViewModel
        
    // Environment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // Notes preview
    @State private var isNotesPreviewEnabled: Bool = false
    
    // Field focus
    private enum FocusField: Hashable {
        case landmarkName
        case address
        case emoji
    }
    @FocusState private var focusField: FocusField?
    
    var body: some View {
        Form {
            saveError
            locationSearchSection
            detailsSection
            categoriesSection
            notesSection
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
            await viewModel.initializeLocation(using: locationService)
            viewModel.loadCategories(from: modelContext)
        }
        .onAppear {
            focusField = .landmarkName
        }
        .onChange(of: viewModel.saveState) { _, newState in
            if case .saved = newState {
                dismiss()
            }
        }
        .onChange(of: viewModel.addressSearchState) { _, newState in
            switch newState {
            case .searchResolved(let locationInfo):
                if self.viewModel.name.isEmpty {
                    self.viewModel.name = locationInfo.formattedDescription
                }
            default: break
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var categoriesSection: some View {
        Section(
            header: Text("Categories"),
            footer: Text("Categorize this landmarks for map filtering.")
        ) {
            HStack {
                // A flow layout of categories in edit mode
                CategoryFlow(categories: $viewModel.categories, mode: .edit)

                Spacer()
                
                // A menu of possible categories to add to the landmark
                Menu {
                    ForEach(viewModel.unassignedCategories, id: \.id) { category in
                        Button(category.name) {
                            withAnimation(.bouncy) {
                                viewModel.addCategory(category)
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
        switch viewModel.saveState {
        case .saveInitial, .saved:
            EmptyView()
        case .saveFailed(let error):
            ErrorView(shortMessage: "failed-to-save".localized, error: error)
        }
    }
    
    private var detailsSection: some View {
        Section(
            header: Text("details".localized),
            footer: Text("Pick a name and an emoji to appear on the map.")
        ) {
            HStack(alignment: .lastTextBaseline) {
                
                // Landmark name input
                TextField("name".localized, text: $viewModel.name,
                          onEditingChanged: { _ in
                })
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled(false)
                .focused($focusField, equals: .landmarkName)
                
                // Landmark name clear button
                Button {
                    viewModel.name = ""
                    focusField = .landmarkName
                } label: {
                    Image(systemName: "xmark.circle")
                }
            }
            
            HStack {
                // Emoji selector
                TextField("emoji-placeholder", text: $viewModel.emoji)
                    .keyboardType(.emoji ?? .default)
                    .focused($focusField, equals: .emoji)
                LandmarkMapAnnotation(emoji: self.viewModel.emoji)
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
                MarkdownPreview(markdown: viewModel.notes)
            } else {
                TextEditor(text: $viewModel.notes)
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
        Section(
            header: Text("location".localized),
            footer: landmarkDescription
        ) {
            if case .create = viewModel.mode {
                HStack {
                    TextField(
                        "addr-or-location-name".localized,
                        text: $viewModel.locationSearchInput)
                    .submitLabel(.search)
                    .textInputAutocapitalization(.none)
                    .autocorrectionDisabled(false)
                    Button {
                        Task {
                            await viewModel.searchByText(using: addressLookupService)
                        }
                    } label: {
                        Image(systemName: "location.magnifyingglass")
                    }
//                    Button {
//                        Task {
//                            await viewModel.searchByCurrentLocation(using: locationService)
//                        }
//                    } label: {
//                        Image(systemName: "location")
//                    }
                }
            }
        }
    }

    private var locationSearchSectionOld: some View {
        Section("location".localized) {
            HStack {
                TextField(
                    "addr-or-location-name".localized,
                    text: $viewModel.locationSearchInput)
                .submitLabel(.search)
                .textInputAutocapitalization(.none)
                .autocorrectionDisabled(false)
                Button {
                    Task {
                        await viewModel.searchByText(using: addressLookupService)
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                Button {
                    Task {
                        await viewModel.searchByCurrentLocation(using: locationService)
                    }
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
            viewModel.save(using: LandmarkStore(modelContext: modelContext))
        }
        .disabled(!viewModel.isSaveEnabled)
    }
    
    @ViewBuilder
    private var landmarkDescription: some View {
        switch viewModel.addressSearchState {
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


#if DEBUG

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

#endif // DEBUG

