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
    
    var id: String { rawValue }
}
