//
//  MarkdownPreview.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/18/26.
//
import SwiftUI

/// Renders the given text as markdown, with a highlight effect,
/// or as plain text if the markdown rendering fails.
struct MarkdownPreview: View {
    
    /// The markdown text to render
    let markdown: String
    
    var body: some View {
        if let rendered = markdown.withMarkdown {
            Text(rendered)
                .previewStyle()
        } else {
            Text(markdown)
                .previewStyle()
        }
    }
}

#if DEBUG

#Preview("Markdown") {
    MarkdownPreview(markdown: "Hi! I'm _markdown_!  So **bold** of me.")
}

#Preview("Plain text") {
    MarkdownPreview(markdown: "Hi! I'm plain text!")
}

#endif // DEBUG
