//
//  StringExtensions.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//

extension String {
    
    // TODO patmcg add unit tests

    /// Determines whether this string is populated with any non-whitespace text
    var isPopulated: Bool {
        // TODO patmcg add unit tests
        !trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Returns the localized version of this string.
    ///
    /// This computed property provides a convenient way to access localized strings
    /// from the app's String Catalog (Localizable.xcstrings).
    ///
    /// Example usage:
    /// ```swift
    /// let title = "My Places".localized
    /// Button("Save".localized) { save() }
    /// ```
    var localized: String {
        String(localized: .init(self))
    }
}
