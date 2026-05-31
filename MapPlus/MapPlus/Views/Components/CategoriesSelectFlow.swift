//
//  CategoriesSelectFlow.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 4/16/26.
//

import SwiftUI
import SwiftData
import Flow

/// Displays landmark categories, allowing individual ones to be selected or unselected.
/// Once presented, any of the known categories could become selected or deselected.
struct CategoriesSelectFlow: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LandmarkCategory.name) private var allCategories: [LandmarkCategory]
    
    @State private var categoriesService: SelectedCategoriesService?
    @State private var viewModel: CategoriesSelectFlowViewModel?
    @State private var isShowingEditView = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button(
                    action: {
                        dismiss()
                    },
                    label: {
                      Image(systemName: "xmark.circle")
                  })

                Spacer()
                
                HStack(spacing: 8) {
                    Button("clear".localized) {
                        viewModel?.clearAllSelections()
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel?.hasSelectedCategories != true)
                    
                    Divider()
                        .frame(height: 20)
                    
                    Button("edit".localized) {
                        isShowingEditView = true
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            // Filter mode picker - only shown when 2+ categories are selected
            if viewModel?.shouldShowFilterModePicker == true {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("filter-mode".localized)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Picker("filter-mode".localized, selection: Binding(
                            get: { viewModel?.filterMode ?? .matchAny },
                            set: { viewModel?.setFilterMode($0) }
                        )) {
                            Text("match-any".localized).tag(CategoryFilterMode.matchAny)
                            Text("match-all".localized).tag(CategoryFilterMode.matchAll)
                        }
                        .pickerStyle(.segmented)
                        .fixedSize()
                    }
                    
                    // Helpful explanation text
                    if let filterMode = viewModel?.filterMode {
                        Text(filterMode == .matchAny 
                            ? "match-any-explanation".localized 
                            : "match-all-explanation".localized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            ScrollView {
                HFlow {
                    ForEach(allCategories) { category in
                        CategoryCapsule(
                            category: category,
                            isSelectable: true,
                            action: nil
                        )
                    }
                }
            }
        }
        .animation(.default, value: viewModel?.shouldShowFilterModePicker)
        .onAppear {
            if categoriesService == nil {
                categoriesService = SelectedCategoriesService(modelContext: modelContext)
            }
            if viewModel == nil, let service = categoriesService {
                viewModel = CategoriesSelectFlowViewModel(service: service)
            }
        }
        .sheet(isPresented: $isShowingEditView) {
            CategoriesEditView()
        }
    }
}

#if DEBUG

private struct SelectedCategoriesView: View {
    
    @Query private var selectedCategoriesForPreview: [SelectedCategories]
    
    private var selectedCategories: [LandmarkCategory] {
        selectedCategoriesForPreview.first?.categories ?? []
    }
    
    var body: some View {
        Text("selected-categories".localized).bold()
        let selected = selectedCategories.map{ $0.name }.joined(separator: ", ")
        Text(selected)
    }
}

#Preview("Basic") {
    VStack {
        CategoriesSelectFlow()
        SelectedCategoriesView()
    }
    .modelContainer(
        try! ModelContainer.inMemorySampleContainer()
    )
}

#Preview("Many") {
    VStack {
        CategoriesSelectFlow()
        SelectedCategoriesView()
    }
    .modelContainer(
        try! ModelContainer.inMemorySampleContainer(
            numExtraCategories: 50
        )
    )
}

#endif // DEBUG
