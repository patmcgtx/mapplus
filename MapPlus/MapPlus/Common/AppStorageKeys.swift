//
//  AppStorageKeys.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 6/1/26.
//

/// Keys for storing values in AppStorage
enum AppStorageKeys: String, CaseIterable, Identifiable {
    
    case theme
    
    var id: String { rawValue }
}
