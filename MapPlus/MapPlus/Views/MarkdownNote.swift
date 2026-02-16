//
//  MarkdownNote.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/16/26.
//
import SwiftUI

struct MarkdownNote: View {
    var body: some View {
        if let markdownNote = "markdown-note".localized.withMarkdown {
            Text(markdownNote)
        } else {
            Text("markdown-note".localized)
        }
    }
}

#Preview {
    MarkdownNote()
}
