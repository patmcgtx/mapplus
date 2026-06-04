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
    
    /// The landmark's symbol to display
    let symbol: String
        
    // Constants
    private let annotationPadding: CGFloat = 10
    private let minBackgroundOpacity = 0.33
    private let maxBackgroundOpacity: CGFloat = 0.67
    private let startGradientRadius = 2.0
    private let endGradientRadius: CGFloat = 8.0
    
    var body: some View {
        Text(String(symbol))
            .font(.headline)
            .foregroundStyle(.primary)
            .padding(annotationPadding)
            .background(fillBackground)
    }
    
    // View helpers
    
    @ViewBuilder
    private var fillBackground: some View {
        Capsule()
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
    
    let landmarkSymbol: String
    
    var body: some View {
        ForEach(MapPlusTheme.allCases) { theme in
            HStack{
                Text(theme.localizedName)
                LandmarkMapAnnotation(symbol: landmarkSymbol)
            }
            .apply(theme: theme)
        }
    }
}

#if DEBUG

#Preview("Cart") {
    AnnotationPreview(landmarkSymbol: "🛒")
}

#Preview("Coffee") {
    AnnotationPreview(landmarkSymbol: "☕️")
}

#Preview("Letter") {
    AnnotationPreview(landmarkSymbol: "P")
}

#Preview("Letters") {
    AnnotationPreview(landmarkSymbol: "PM")
}

#Preview("Double") {
    AnnotationPreview(landmarkSymbol: "☕️🔥")
}

#Preview("Triple") {
    AnnotationPreview(landmarkSymbol: "☕️🔥☺️")
}

#Preview("Overlap") {
    ZStack {
        LandmarkMapAnnotation(symbol: "📍")
        LandmarkMapAnnotation(symbol: "📍")
            .offset(CGSize(width: 20, height: 20))
        LandmarkMapAnnotation(symbol: "📍")
            .offset(CGSize(width: 40, height: 40))
    }
    .padding(40)
    .background(.green)
    .cornerRadius(10)
}

#endif // DEBUG
