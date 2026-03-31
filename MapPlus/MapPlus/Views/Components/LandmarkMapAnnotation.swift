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

    @Environment(\.theme) private var theme

    private let annotationPadding: CGFloat = 10

    var body: some View {
            Text(String(emoji))
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(annotationPadding)
                .background(annotationBackground)
    }

    @ViewBuilder
    private var annotationBackground: some View {
            Circle()
                .fill(standardRadialGradient)
                .strokeBorder(Color.accentColor, lineWidth: 2.0)
    }

    private var standardRadialGradient: RadialGradient {
        RadialGradient(
            colors: [
                Color.accentColor.opacity(0.33),
                Color.accentColor.opacity(0.67)
            ],
            center: .center,
            startRadius: 2,
            endRadius: annotationPadding + 8
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

#Preview("Cart") {
    AnnotationPreview(landmarkEmoji: "🛒")
}

#Preview("Coffee") {
    AnnotationPreview(landmarkEmoji: "☕️")
}

#Preview("Stars") {
    AnnotationPreview(landmarkEmoji: "✨")
}

#Preview("Check") {
    AnnotationPreview(landmarkEmoji: "✔️")
}

#Preview("Sword") {
    AnnotationPreview(landmarkEmoji: "⚔️")
}

#Preview("Initial") {
    AnnotationPreview(landmarkEmoji: "P")
}

#Preview("Blue") {
    AnnotationPreview(landmarkEmoji: "P")
            .padding(40)
            .background(.blue)
            .cornerRadius(10)
}

#Preview("Green") {
    AnnotationPreview(landmarkEmoji: "P")
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
