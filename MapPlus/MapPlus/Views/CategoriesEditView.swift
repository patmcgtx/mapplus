//
//  CategoriesEditView.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 4/25/26.
//

import SwiftUI
import SwiftData

/// A view for managing landmark categories - adding, renaming, and deleting them.
struct CategoriesEditView: View {

    // MARK: Environment
    
    @Environment(\.dismiss)
    private var dismiss
    
    @Environment(\.modelContext)
    private var modelContext

    // MARK: App storage
    
    @AppStorage(AppStorageKeys.theme.rawValue)
    private var theme: MapPlusTheme = .cupertino

    // MARK: Persistence
    
    @Query(sort: \LandmarkCategory.name)
    private var allCategories: [LandmarkCategory]
    
    // MARK: View state
    
    @State
    private var viewModel: CategoriesEditViewModel?
    
    // MARK: Focus
    
    @FocusState
    private var isAddFieldFocused: Bool
    
    // MARK: Views
    
    var body: some View {
        NavigationStack {
            List {
                // Add new category section
                Section {
                    HStack {
                        TextField("new-category-name".localized, text: Binding(
                            get: { viewModel?.newCategoryName ?? "" },
                            set: { viewModel?.newCategoryName = $0 }
                        ))
                            .focused($isAddFieldFocused)
                            .onSubmit {
                                if viewModel?.addCategory(allCategories: allCategories) == true {
                                    isAddFieldFocused = true
                                }
                            }
                        
                        Button(action: {
                            if viewModel?.addCategory(allCategories: allCategories) == true {
                                isAddFieldFocused = true
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(theme.tintColor)
                        }
                        .disabled(viewModel?.newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
                        .accessibilityLabel("add-category".localized)
                    }
                } header: {
                    Text("add-category".localized)
                }
                
                // Existing categories section
                Section {
                    ForEach(allCategories) { category in
                        if viewModel?.editingCategory?.id == category.id {
                            // Edit mode for this category
                            HStack {
                                TextField("category-name".localized, text: Binding(
                                    get: { viewModel?.editedName ?? "" },
                                    set: { viewModel?.editedName = $0 }
                                ))
                                    .textFieldStyle(.roundedBorder)
                                    .onSubmit {
                                        viewModel?.saveEdit(for: category, allCategories: allCategories)
                                    }
                                
                                Button("save".localized) {
                                    viewModel?.saveEdit(for: category, allCategories: allCategories)
                                }
                                .buttonStyle(.bordered)
                                .disabled(viewModel?.editedName.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
                                
                                Button("cancel".localized) {
                                    viewModel?.cancelEdit()
                                }
                                .buttonStyle(.bordered)
                            }
                        } else {
                            // Normal display mode
                            HStack {
                                Text(category.name)
                                
                                
                                let numItems = category.landmarks.count
                                Text("\(numItems) landmarks")
                                    .fontWeight(.thin)

                                Spacer()

                                Button(action: {
                                    withAnimation {
                                        viewModel?.startEditing(category)
                                    }
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundStyle(theme.tintColor)
                                }
                                .buttonStyle(.borderless)
                                .accessibilityLabel("rename-category".localized)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    viewModel?.showingDeleteAlert = category
                                } label: {
                                    Label("delete".localized, systemImage: "trash")
                                }
                            }
                        }
                    }
                } header: {
                    Text("existing-categories")
                } footer: {
                    Text("category-deletion-explanation")
                }
            }
            .navigationTitle("edit-categories".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("done".localized) {
                        dismiss()
                    }
                }
            }
            .alert(
                "delete-category-title".localized,
                isPresented: Binding(
                    get: { viewModel?.showingDeleteAlert != nil },
                    set: { if !$0 { viewModel?.showingDeleteAlert = nil } }
                ),
                presenting: viewModel?.showingDeleteAlert
            ) { category in
                Button("cancel".localized, role: .cancel) {
                    viewModel?.showingDeleteAlert = nil
                }
                Button("delete".localized, role: .destructive) {
                    viewModel?.deleteCategory(category)
                    viewModel?.showingDeleteAlert = nil
                }
            } message: { category in
                Text("confirm-delete-category-\(category.name)")
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = CategoriesEditViewModel(modelContext: modelContext)
                }
            }
        }
    }
}

#if DEBUG

#Preview {
    CategoriesEditView()
        .modelContainer(try! ModelContainer.inMemorySampleContainer())
}

#endif // DEBUG
