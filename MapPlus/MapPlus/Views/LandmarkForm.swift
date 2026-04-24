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

    // UI state
    @State private var isNotesPreviewEnabled: Bool = false
    @State private var isNameEdited: Bool = false

    // Field focus
    private enum FocusField: Hashable {
        case landmarkName
        case address
        case emoji
    }
    @FocusState private var focusField: FocusField?
    
    var body: some View {
        Form {
            previewSection
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
        .onChange(of: viewModel.saveState) { _, newState in
            if case .saved = newState {
                dismiss()
            }
        }
        .onChange(of: viewModel.addressSearchState) { _, newState in
            if !isNameEdited, case .searchResolved(let locationInfo) = newState {
                self.viewModel.name = locationInfo.briefDescription
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var categoriesSection: some View {
        Section(
            header: Text("Categories"),
            footer: Text("landmark-form-categories-instructions".localized)
        ) {
            HStack {
                // A flow layout of categories in edit mode
                CategoriesEditFlow(categories: $viewModel.categories)

                Spacer()
                
                // A menu of possible categories to add to the landmark
                Menu {
                    ForEach(viewModel.unassignedCategories) { category in
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
        Section("details".localized) {
            HStack(alignment: .lastTextBaseline) {
                
                // Landmark name input
                TextField("name".localized, text: $viewModel.name,
                          onEditingChanged: { _ in
                    isNameEdited = true
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
                // TODO patmcg allow full keyboard in settings
                TextField("emoji-placeholder", text: $viewModel.emoji)
                    .keyboardType(.emoji ?? .default)
                    .focused($focusField, equals: .emoji)
                Button {
                    viewModel.emoji = ""
                    focusField = .emoji
                } label: {
                    Image(systemName: "xmark.circle")
                }
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
        Section("location".localized) {
            if case .create = viewModel.mode {
                HStack {
                    TextField(
                        "addr-or-location-name".localized,
                        text: $viewModel.locationSearchInput)
                    .submitLabel(.search)
                    .textInputAutocapitalization(.none)
                    .autocorrectionDisabled(false)
                    .onSubmit {
                        Task {
                            await viewModel.searchByText(using: addressLookupService)
                        }
                    }
                    Button {
                        Task {
                            await viewModel.searchByText(using: addressLookupService)
                        }
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
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
        Button {
            viewModel.save(using: LandmarkStore(modelContext: modelContext))
        } label: {
            Image(systemName: "checkmark")
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
            Text(addressInfo.fullDescription)
        case .searchFailed(let error):
            ErrorView(shortMessage: "location-search-failed".localized, error: error)
        }
    }
    
    @ViewBuilder
    private var previewSection: some View {
        Section("preview".localized) {
            HStack {
                HStack {
                    
                    // Landmark icon
                    VStack {
                        Spacer()
                        LandmarkMapAnnotation(emoji: viewModel.emoji)
                        Spacer()
                        Text(viewModel.name).bold()
                        Spacer()
                    }
                    .multilineTextAlignment(.center)
                    .padding()
                    Spacer()
                    
                    // Landmark description
                    switch viewModel.addressSearchState {
                    case .searchInitial, .searching:
                        Spacer()
                        ProgressView()
                        Spacer()
                    case .searchResolved(let addressInfo):
                        Spacer()
                        Text(addressInfo.fullDescription)
                        Spacer()
                    case .searchFailed(let error):
                        ErrorView(shortMessage: "location-search-failed".localized, error: error)
                    }
                }
            }
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

