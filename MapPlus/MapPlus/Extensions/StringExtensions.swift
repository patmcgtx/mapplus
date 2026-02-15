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
}
