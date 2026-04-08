//
//  MarkdownNote.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/16/26.
//
import SwiftUI

/// A note about working with Markdown with a link out to a Markdown reference
struct MarkdownUsageNote: View {
    var body: some View {
        if let markdownNote = "markdown-note".localized.withMarkdown {
            Text(markdownNote)
        } else {
            Text("markdown-note".localized)
        }
    }
}

#if DEBUG

#Preview {
    MarkdownUsageNote()
}

#endif // DEBUG
