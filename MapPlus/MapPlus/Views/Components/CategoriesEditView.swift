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
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.theme) private var theme: MapPlusTheme
    
    @Query(sort: \LandmarkCategory.name) private var allCategories: [LandmarkCategory]
    
    @State private var newCategoryName: String = ""
    @State private var editingCategory: LandmarkCategory?
    @State private var editedName: String = ""
    @State private var showingDeleteAlert: LandmarkCategory?
    @FocusState private var isAddFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            List {
                // Add new category section
                Section {
                    HStack {
                        TextField("new-category-name".localized, text: $newCategoryName)
                            .focused($isAddFieldFocused)
                            .onSubmit {
                                addCategory()
                            }
                        
                        Button(action: addCategory) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.green)
                        }
                        .disabled(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                } header: {
                    Text("add-category".localized)
                }
                
                // Existing categories section
                Section {
                    ForEach(allCategories) { category in
                        if editingCategory?.id == category.id {
                            // Edit mode for this category
                            HStack {
                                TextField("category-name".localized, text: $editedName)
                                    .textFieldStyle(.roundedBorder)
                                    .onSubmit {
                                        saveEdit(for: category)
                                    }
                                
                                Button("save".localized) {
                                    saveEdit(for: category)
                                }
                                .buttonStyle(.bordered)
                                .disabled(editedName.trimmingCharacters(in: .whitespaces).isEmpty)
                                
                                Button("cancel".localized) {
                                    cancelEdit()
                                }
                                .buttonStyle(.bordered)
                            }
                        } else {
                            // Normal display mode
                            HStack {
                                Text(category.name)
                                
                                Spacer()
                                
                                Button(action: {
                                    startEditing(category)
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundStyle(theme.tintColor)
                                }
                                .buttonStyle(.borderless)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    showingDeleteAlert = category
                                } label: {
                                    Label("delete".localized, systemImage: "trash")
                                }
                            }
                        }
                    }
                } header: {
                    Text("existing-categories".localized)
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
                isPresented: .constant(showingDeleteAlert != nil),
                presenting: showingDeleteAlert
            ) { category in
                Button("cancel".localized, role: .cancel) {
                    showingDeleteAlert = nil
                }
                Button("delete".localized, role: .destructive) {
                    deleteCategory(category)
                    showingDeleteAlert = nil
                }
            } message: { category in
                Text("delete-category-message-\(category.name)".localized)
            }
        }
    }
    
    // MARK: - Actions
    
    private func addCategory() {
        let trimmedName = newCategoryName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        // Check if category already exists
        if allCategories.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) {
            // Could show an error here
            return
        }
        
        let newCategory = LandmarkCategory(name: trimmedName)
        modelContext.insert(newCategory)
        
        do {
            try modelContext.save()
            newCategoryName = ""
            isAddFieldFocused = true
        } catch {
            print("Failed to add category: \(error)")
        }
    }
    
    private func startEditing(_ category: LandmarkCategory) {
        editingCategory = category
        editedName = category.name
    }
    
    private func saveEdit(for category: LandmarkCategory) {
        let trimmedName = editedName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        // Check if another category already has this name
        if allCategories.contains(where: { 
            $0.id != category.id && $0.name.lowercased() == trimmedName.lowercased() 
        }) {
            // Could show an error here
            return
        }
        
        category.name = trimmedName
        
        do {
            try modelContext.save()
            cancelEdit()
        } catch {
            print("Failed to save category edit: \(error)")
        }
    }
    
    private func cancelEdit() {
        editingCategory = nil
        editedName = ""
    }
    
    private func deleteCategory(_ category: LandmarkCategory) {
        modelContext.delete(category)
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete category: \(error)")
        }
    }
}

#if DEBUG

#Preview {
    CategoriesEditView()
        .modelContainer(try! ModelContainer.inMemorySampleContainer())
}

#endif // DEBUG
