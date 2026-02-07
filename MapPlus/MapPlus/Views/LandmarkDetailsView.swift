//
//  LandmarkDetailsView.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/7/26.
//

import SwiftUI

struct LandmarkDetailsView: View {

    let landmark: Landmark

    @Environment(\.dismiss) private var dismiss
    
    @State private var isEditing: Bool = false

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
                    Text(landmark.notes)
                        .padding(.leading)
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
            // TODO patmcg add cancel + save buttons to this form
            LandmarkForm(mode: .edit(landmark))
        }
    }
}

#Preview {
    LandmarkDetailsView(landmark: LandmarkSampleData().capital)
}
