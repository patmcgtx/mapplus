//
//  MarkdownPreviewHighlight.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/18/26.
//

import SwiftUI

/// View modifier to add a subtle highlight indicating that this is "preview" text
struct PreviewHighlight: ViewModifier {

    private let notesPreviewBackgroundColor: Color = Color.accentColor.opacity(0.2)

    func body(content: Content) -> some View {
        content
            .padding()
            .background(notesPreviewBackgroundColor)
    }
}

extension View {

    /// View modifier shortcut to add a subtle highlight indicating that this is "preview" text
    func previewStyle() -> some View {
        modifier(PreviewHighlight())
    }
}
