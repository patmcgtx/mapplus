//
//  StringExtensions.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//

// TODO patmcg add unit tests
extension String {
    
    // TODO patmcg doc
    var isPopulated: Bool {
        !trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
