//
//  LandmarkMapAnnotation.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/14/26.
//
import SwiftUI
import MapKit

/// A view of an individual landmark placed on the map.
/// The map itself will display the landmark name; this is just the visual to go with it.
struct LandmarkMapAnnotation: View {
 
    /// The landmark's emoji to display
    let emoji: String
 
    var body: some View {
            Text(String(emoji))
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(10)
                .background(
                    Circle()
//                        .fill(Color.secondary)
                        .fill(Color.accentColor)
                        .strokeBorder(.primary, lineWidth: 2)
                )
    }
}

// MARK: - Previews

private struct AnnotationPreview: View {
    
    let landmarkEmoji: String
    
    var body: some View {
        ForEach(MapPlusTheme.allCases) { theme in
            HStack{
                Text(theme.localizedName)
                LandmarkMapAnnotation(emoji: landmarkEmoji)
                    .apply(theme: theme)
            }
        }
    }
}

#Preview("Coffee") {
    AnnotationPreview(landmarkEmoji: "☕️")
}

#Preview("Many") {
    AnnotationPreview(landmarkEmoji: "🐢🦞📚")
}

#Preview("Initials") {
    AnnotationPreview(landmarkEmoji: "PM")
}

#Preview("Blue") {
    AnnotationPreview(landmarkEmoji: "PM")
            .padding(40)
            .background(.blue)
            .cornerRadius(10)
}

#Preview("Green") {
    AnnotationPreview(landmarkEmoji: "PM")
            .padding(40)
            .background(.green)
            .cornerRadius(10)
}

#Preview("Overlap") {
    ZStack {
        LandmarkMapAnnotation(emoji: "📍")
        LandmarkMapAnnotation(emoji: "📍")
            .offset(CGSize(width: 20, height: 20))
        LandmarkMapAnnotation(emoji: "📍")
            .offset(CGSize(width: 40, height: 40))
    }
    .padding(40)
    .background(.green)
    .cornerRadius(10)
}
