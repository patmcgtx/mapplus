//
//  ThemePreview.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/5/26.
//
import SwiftUI

#if DEBUG

/// A view for sampling a theme
struct ThemePreview: View {
    
    /// The theme to show off
    let theme: MapPlusTheme
    
    var body: some View {
        HStack {
            Spacer(minLength: 40)
            VStack(alignment: .center) {
                Text("Hello, World!")
                Text("This is \(theme.localizedName).")
                HStack {
                    Spacer()
                    TextField("Search", text: .constant(""))
                        .frame(maxWidth: 200)
                    Spacer()
                }
                Button("(Im)press me!") {}
                CategoryCapsule(
                    category: LandmarkCategory(name: "View"),
                    mode: .view,
                    fromCategories: .constant([])
                )
                CategoryCapsule(
                    category: LandmarkCategory(name: "Edit"),
                    mode: .edit,
                    fromCategories: .constant([])
                )
                LandmarkMapAnnotation(emoji: "P")
            }
            .padding()
            .border(.primary, width: 1)
            Spacer(minLength: 40)
        }
    }
}

#Preview() {
    ForEach(MapPlusTheme.allCases) { theme in
        ThemePreview(theme: theme)
            .apply(theme: theme)
    }
}

#endif // DEBUG
