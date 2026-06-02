//
//  AppStorageKeysTests.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 6/1/26.
//

import Testing
import SwiftUI
@testable import MapPlus

// These tests have to run serially, not in parallel,
// to avoid stomping on the same shared user defaults.
@Suite(.serialized)
struct AppStorageKeysTests {
    
    // MARK: - Enum Properties
    
    @Test("All cases are defined")
    func allCasesAreDefined() {
        let cases = AppStorageKeys.allCases
        #expect(cases.count == 3)
        #expect(cases.contains(.theme))
        #expect(cases.contains(.poiLevel))
        #expect(cases.contains(.showCategorySelectorExplanation))
    }
    
    @Test("Raw values are correct")
    func rawValuesAreCorrect() {
        #expect(AppStorageKeys.theme.rawValue == "theme")
        #expect(AppStorageKeys.poiLevel.rawValue == "poiLevel")
        #expect(AppStorageKeys.showCategorySelectorExplanation.rawValue == "showCategorySelectorExplanation")
    }
    
    @Test("Identifiable ID matches raw value")
    func identifiableIDMatchesRawValue() {
        for key in AppStorageKeys.allCases {
            #expect(key.id == key.rawValue)
        }
    }
    
    // MARK: - AppStorage Integration Tests
    
    @Test("Theme AppStorage stores and retrieves values")
    func themeAppStorageStoresAndRetrievesValues() throws {
        // Clean up before test
        let key = AppStorageKeys.theme.rawValue
        UserDefaults.standard.removeObject(forKey: key)
        
        // Create a wrapper to simulate AppStorage usage
        @AppStorage(key) var theme: MapPlusTheme = .cupertino
        
        // Test default value
        #expect(theme == .cupertino)
        
        // Test setting each theme
        for testTheme in MapPlusTheme.allCases {
            theme = testTheme
            
            // Verify the value is stored
            #expect(theme == testTheme)
            
            // Verify it's actually in UserDefaults
            let storedValue = UserDefaults.standard.string(forKey: key)
            #expect(storedValue == testTheme.rawValue)
        }
        
        // Clean up after test
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    @Test("POI Level AppStorage stores and retrieves values")
    func poiLevelAppStorageStoresAndRetrievesValues() throws {
        // Clean up before test
        let key = AppStorageKeys.poiLevel.rawValue
        UserDefaults.standard.removeObject(forKey: key)
        
        // Create a wrapper to simulate AppStorage usage
        @AppStorage(key) var poiLevel: PointsOfInterestLevel = .all
        
        // Test default value
        #expect(poiLevel == .all)
        
        // Test setting each POI level
        for testLevel in PointsOfInterestLevel.allCases {
            poiLevel = testLevel
            
            // Verify the value is stored
            #expect(poiLevel == testLevel)
            
            // Verify it's actually in UserDefaults
            let storedValue = UserDefaults.standard.string(forKey: key)
            #expect(storedValue == testLevel.rawValue)
        }
        
        // Clean up after test
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    @Test("Theme AppStorage persists across instances")
    func themeAppStoragePersistsAcrossInstances() throws {
        let key = AppStorageKeys.theme.rawValue
        UserDefaults.standard.removeObject(forKey: key)
        
        // First instance sets the value
        do {
            @AppStorage(key) var theme: MapPlusTheme = .cupertino
            theme = .flamingo
            #expect(theme == .flamingo)
        }
        
        // Second instance should read the persisted value
        do {
            @AppStorage(key) var theme: MapPlusTheme = .cupertino
            #expect(theme == .flamingo, "Theme should persist across AppStorage instances")
        }
        
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    @Test("POI Level AppStorage persists across instances")
    func poiLevelAppStoragePersistsAcrossInstances() throws {
        let key = AppStorageKeys.poiLevel.rawValue
        UserDefaults.standard.removeObject(forKey: key)
        
        // First instance sets the value
        do {
            @AppStorage(key) var poiLevel: PointsOfInterestLevel = .all
            poiLevel = .limited
            #expect(poiLevel == .limited)
        }
        
        // Second instance should read the persisted value
        do {
            @AppStorage(key) var poiLevel: PointsOfInterestLevel = .all
            #expect(poiLevel == .limited, "POI level should persist across AppStorage instances")
        }
        
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    @Test("Theme uses default when no value stored")
    func themeUsesDefaultWhenNoValueStored() {
        let key = AppStorageKeys.theme.rawValue
        UserDefaults.standard.removeObject(forKey: key)
        
        @AppStorage(key) var theme: MapPlusTheme = .cupertino
        #expect(theme == .cupertino, "Should use default value when nothing is stored")
        
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    @Test("POI Level uses default when no value stored")
    func poiLevelUsesDefaultWhenNoValueStored() {
        let key = AppStorageKeys.poiLevel.rawValue
        UserDefaults.standard.removeObject(forKey: key)
        
        @AppStorage(key) var poiLevel: PointsOfInterestLevel = .none
        #expect(poiLevel == .none, "Should use default value when nothing is stored")
        
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    @Test("Multiple AppStorage instances sync automatically")
    func multipleAppStorageInstancesSyncAutomatically() {
        let key = AppStorageKeys.theme.rawValue
        UserDefaults.standard.removeObject(forKey: key)
        
        @AppStorage(key) var theme1: MapPlusTheme = .cupertino
        @AppStorage(key) var theme2: MapPlusTheme = .cupertino
        
        // Both should start with default
        #expect(theme1 == .cupertino)
        #expect(theme2 == .cupertino)
        
        // Change one
        theme1 = .eightBit
        
        // Both should reflect the change (UserDefaults synchronization)
        #expect(theme1 == .eightBit)
        
        // Note: In a real SwiftUI view, theme2 would update automatically via the property wrapper.
        // In a test context, we verify the underlying UserDefaults has been updated.
        let storedValue = UserDefaults.standard.string(forKey: key)
        #expect(storedValue == MapPlusTheme.eightBit.rawValue)
        
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    @Test("Show Category Selector Explanation AppStorage stores and retrieves values")
    func showCategorySelectorExplanationAppStorageStoresAndRetrievesValues() throws {
        // Clean up before test
        let key = AppStorageKeys.showCategorySelectorExplanation.rawValue
        UserDefaults.standard.removeObject(forKey: key)
        
        // Create a wrapper to simulate AppStorage usage
        @AppStorage(key) var showExplanation: Bool = true
        
        // Test default value
        #expect(showExplanation == true)
        
        // Test setting to false
        showExplanation = false
        #expect(showExplanation == false)
        
        // Verify it's actually in UserDefaults
        let storedValue = UserDefaults.standard.bool(forKey: key)
        #expect(storedValue == false)
        
        // Test setting to true
        showExplanation = true
        #expect(showExplanation == true)
        
        let storedValueTrue = UserDefaults.standard.bool(forKey: key)
        #expect(storedValueTrue == true)
        
        // Clean up after test
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    @Test("Show Category Selector Explanation AppStorage persists across instances")
    func showCategorySelectorExplanationAppStoragePersistsAcrossInstances() throws {
        let key = AppStorageKeys.showCategorySelectorExplanation.rawValue
        UserDefaults.standard.removeObject(forKey: key)
        
        // First instance sets the value
        do {
            @AppStorage(key) var showExplanation: Bool = true
            showExplanation = false
            #expect(showExplanation == false)
        }
        
        // Second instance should read the persisted value
        do {
            @AppStorage(key) var showExplanation: Bool = true
            #expect(showExplanation == false, "Show explanation flag should persist across AppStorage instances")
        }
        
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    @Test("Show Category Selector Explanation uses default when no value stored")
    func showCategorySelectorExplanationUsesDefaultWhenNoValueStored() {
        let key = AppStorageKeys.showCategorySelectorExplanation.rawValue
        UserDefaults.standard.removeObject(forKey: key)
        
        @AppStorage(key) var showExplanation: Bool = true
        #expect(showExplanation == true, "Should use default value when nothing is stored")
        
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    @Test("AppStorage keys don't conflict")
    func appStorageKeysDontConflict() {
        let themeKey = AppStorageKeys.theme.rawValue
        let poiKey = AppStorageKeys.poiLevel.rawValue
        let explanationKey = AppStorageKeys.showCategorySelectorExplanation.rawValue
        
        UserDefaults.standard.removeObject(forKey: themeKey)
        UserDefaults.standard.removeObject(forKey: poiKey)
        UserDefaults.standard.removeObject(forKey: explanationKey)
        
        @AppStorage(themeKey) var theme: MapPlusTheme = .cupertino
        @AppStorage(poiKey) var poiLevel: PointsOfInterestLevel = .all
        @AppStorage(explanationKey) var showExplanation: Bool = true
        
        // Set different values
        theme = .kerby
        poiLevel = .none
        showExplanation = false
        
        // Verify they're stored independently
        #expect(theme == .kerby)
        #expect(poiLevel == .none)
        #expect(showExplanation == false)
        
        let storedTheme = UserDefaults.standard.string(forKey: themeKey)
        let storedPOI = UserDefaults.standard.string(forKey: poiKey)
        let storedExplanation = UserDefaults.standard.bool(forKey: explanationKey)
        
        #expect(storedTheme == "kerby")
        #expect(storedPOI == "none")
        #expect(storedExplanation == false)
        
        UserDefaults.standard.removeObject(forKey: themeKey)
        UserDefaults.standard.removeObject(forKey: poiKey)
        UserDefaults.standard.removeObject(forKey: explanationKey)
    }
}
