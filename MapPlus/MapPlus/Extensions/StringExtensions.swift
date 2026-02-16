//
//  StringExtensions.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//

import Foundation

extension String {
    
    /// Returns the localized version of this string.
    ///
    /// This computed property provides a convenient way to access localized strings
    /// from the app's String Catalog (Localizable.xcstrings).
    ///
    /// Example usage:
    /// ```swift
    /// let title = "my-places-title".localized
    /// Button("save-button-title".localized) { save() }
    /// ```
    var localized: String {
        String(localized: .init(self))
    }
        
    /// Creates an`AttributedString` from this string, including markdown formatting.
    /// - Returns:A markdown-formatted an`AttributedString`, or nil if there is an issue
    var withMarkdown: AttributedString? {
        do {
            return try AttributedString(markdown: self)
        } catch {
            return nil
        }
    }
    
    /// Determines whether this string is populated with any non-whitespace text
    var isPopulated: Bool {
        !trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

}
