//
//  StringExtensions.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//

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
    
    /// Determines whether this string is populated with any non-whitespace text
    var isPopulated: Bool {
        !trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

}
