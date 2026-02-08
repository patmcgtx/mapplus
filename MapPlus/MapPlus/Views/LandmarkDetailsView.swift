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

    var body: some View {
        NavigationStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(landmark.notes)
                        .padding()
                    Spacer()
                }
                .padding(.leading)
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
                ToolbarItem(placement: .title) {
                    Text(landmark.name)
                            .font(.headline)
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
