//
//  OtherMap.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/7/26.
//

import SwiftUI
import MapKit

struct MapToolbarView: View {
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        NavigationStack {
            Map(position: $position)
                .navigationTitle("Local Map")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            // Action to recenter or search
                        } label: {
                            Image(systemName: "location.fill")
                        }
                    }
                }
        }
    }
}

#Preview {
    MapToolbarView()
}
