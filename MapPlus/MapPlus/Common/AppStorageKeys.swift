//
//  AppStorageKeys.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 6/1/26.
//

/// Keys for storing values in AppStorage
enum AppStorageKeys: String, CaseIterable, Identifiable {
    
    /// The selected theme
    case theme
    
    /// The selected map Points of Interest level
    case poiLevel
    
    /// Show or hide the category selector explanation
    case showCategorySelectorExplanation
    
    var id: String { rawValue }
}
