//
//  LandmarkDetailView.swift
//  MapPlus
//
//  Created by GitHub Copilot on 2/5/26.
//

import SwiftUI
import MapKit

/// A view that displays details about a selected landmark
struct LandmarkDetailView: View {
    
    let landmark: Landmark
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with dismiss button
            HStack {
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            
            // Content
            VStack(alignment: .leading, spacing: 16) {
                // Icon and name
                HStack(spacing: 12) {
                    Image(systemName: landmark.systemImageName)
                        .font(.title)
                        .foregroundStyle(.blue)
                    
                    Text(landmark.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal)
                
                // Notes section
                if !landmark.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Text(landmark.notes)
                            .font(.body)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: 300)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}

#Preview {
    let sampleLandmark = LandmarkSampleData().sampleData.first ?? Landmark(
        name: "Sample Place",
        notes: "Sample notes",
        formattedAddress: "123 Main St",
        systemImageName: "mappin.circle",
        location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    )
    
    return LandmarkDetailView(
        landmark: sampleLandmark,
        onDismiss: {}
    )
}
