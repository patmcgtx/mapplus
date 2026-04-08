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
        
    // Constants
    private let annotationPadding: CGFloat = 10
    private let minBackgroundOpacity = 0.33
    private let maxBackgroundOpacity: CGFloat = 0.67
    private let startGradientRadius = 2.0
    private let endGradientRadius: CGFloat = 8.0
    
    var body: some View {
        Text(String(emoji))
            .font(.headline)
            .foregroundStyle(.primary)
            .padding(annotationPadding)
            .background(fillBackground)
    }
    
    // View helpers
    
    @ViewBuilder
    private var fillBackground: some View {
        Circle()
            .fill(fillGradient)
            .strokeBorder(Color.accentColor, lineWidth: 2.0)
    }
    
    private var fillGradient: RadialGradient {
        RadialGradient(
            colors: [
                Color.accentColor.opacity(minBackgroundOpacity),
                Color.accentColor.opacity(maxBackgroundOpacity)
            ],
            center: .center,
            startRadius: startGradientRadius,
            endRadius: annotationPadding + endGradientRadius
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
            }
            .apply(theme: theme)
        }
    }
}

#if DEBUG

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

#Preview("Letter") {
    AnnotationPreview(landmarkEmoji: "P")
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

#endif // DEBUG
