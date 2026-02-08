//
//  LandmarkDetailsView.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/7/26.
//

import SwiftUI

// TODO patmcg doc
struct LandmarkDetailsView: View {

    let landmark: Landmark

    @Environment(\.dismiss) private var dismiss
    
    @State private var isEditing: Bool = false

    // Segmented picker
    private enum Section: String, CaseIterable, Identifiable {
        case details = "Details"
        case preview = "Preview"        
        var id: Self { self }
    }
    @State private var selectedSection: Section = .details

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
                        Text(landmark.notes)
                            .padding()
                        Text(landmark.formattedAddress)
                            .font(.footnote)
                            .padding(.leading)
                    case .preview:
                        Text("Prwview Content Here")
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
                        self.isEditing = true
                    }
                }
            }
        }
        .sheet(isPresented: self.$isEditing) {
            NavigationStack {
                LandmarkForm(mode: .edit(landmark))
            }
        }
    }
}

#Preview {
    LandmarkDetailsView(landmark: LandmarkSampleData().capital)
}
