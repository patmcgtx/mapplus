//
//  CategoriesEditorView.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/19/26.
//

import SwiftUI
import SwiftData

/// A view for managing the list of landmark categories:
/// add new ones, rename, change colors, and delete.
struct CategoriesEditorView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \LandmarkCategory.name, order: .forward)
    private var categories: [LandmarkCategory]

    @State private var isAddingCategory: Bool = false
    @State private var categoryToEdit: LandmarkCategory? = nil

    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { category in
                    Button {
                        categoryToEdit = category
                    } label: {
                        HStack {
                            CategoryCapsuleView(category: category)
                            Spacer()
                        }
                    }
                    .tint(.primary)
                }
                .onDelete(perform: deleteCategories)
            }
            .navigationTitle("categories".localized)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("dismiss".localized, systemImage: "xmark") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("add-category".localized, systemImage: "plus") {
                        isAddingCategory = true
                    }
                }
            }
        }
        .sheet(isPresented: $isAddingCategory) {
            CategoryFormView(mode: .add)
        }
        .sheet(item: $categoryToEdit) { category in
            CategoryFormView(mode: .edit(category))
        }
    }

    private func deleteCategories(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(categories[index])
        }
        try? modelContext.save()
    }
}

// MARK: - Category add/edit form

/// A small form sheet for creating or editing a single `LandmarkCategory`.
struct CategoryFormView: View {

    enum Mode {
        case add
        case edit(LandmarkCategory)
    }

    let mode: Mode

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var nameInput: String = ""
    @State private var colorInput: Color = .blue

    var body: some View {
        NavigationStack {
            Form {
                Section("details".localized) {
                    TextField("name".localized, text: $nameInput)
                    ColorPicker("color".localized, selection: $colorInput, supportsOpacity: false)
                }
            }
            .navigationTitle(formTitle)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel".localized) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("save".localized) {
                        saveCategory()
                        dismiss()
                    }
                    .disabled(nameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if case .edit(let category) = mode {
                    nameInput = category.name
                    colorInput = Color(hex: category.colorHex)
                }
            }
        }
    }

    private var formTitle: String {
        switch mode {
        case .add: return "new-category".localized
        case .edit: return "edit-category".localized
        }
    }

    private func saveCategory() {
        switch mode {
        case .add:
            let category = LandmarkCategory(
                name: nameInput.trimmingCharacters(in: .whitespacesAndNewlines),
                colorHex: colorInput.hexString
            )
            modelContext.insert(category)
        case .edit(let category):
            category.name = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
            category.colorHex = colorInput.hexString
        }
        try? modelContext.save()
    }
}

// MARK: - Previews

#Preview {
    CategoriesEditorView()
        .modelContainer(try! ModelContainer.inMemorySampleContainer())
}
