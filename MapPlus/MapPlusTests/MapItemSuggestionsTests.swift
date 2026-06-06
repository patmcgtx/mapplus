//
//  MapItemSuggestionsTests.swift
//  MapPlusTests
//
//  Created by Patrick McGonigle on 6/5/26.
//

import Testing
import MapKit
import Contacts
import FoundationModels
@testable import MapPlus

@Suite("MapItemSynthesizer Tests")
struct MapItemSynthesizerTests {
    
    // MARK: - Test Helpers
    
    /// Helper to create a test MKMapItem with specific properties
    private static func createTestMapItem(
        coordinate: CLLocationCoordinate2D,
        name: String? = nil,
        addressComponents: [String: String]? = nil
    ) -> MKMapItem {
        let mapItem: MKMapItem
        
        if let addressComponents = addressComponents {
            let placemark = MKPlacemark(
                coordinate: coordinate,
                addressDictionary: addressComponents
            )
            mapItem = MKMapItem(placemark: placemark)
        } else {
            mapItem = MKMapItem(
                location: CLLocation(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                ),
                address: nil
            )
        }
        
        mapItem.name = name
        
        return mapItem
    }
    
    // MARK: - LocationAddOns Tests
    
    @Test("LocationAddOns can be initialized")
    func testLocationAddOnsInitialization() {
        let category = LandmarkCategory(name: "Museums")
        let addOns = MapItemSuggestions(
            name: "Art Museum",
            notes: "A famous museum with art collections",
            symbol: "🏛️"
        )
        
        #expect(addOns.name == "Art Museum")
        #expect(addOns.notes == "A famous museum with art collections")
        #expect(addOns.symbol == "🏛️")
    }
    
    @Test("LocationAddOns with various emoji symbols")
    func testLocationAddOnsVariousSymbols() {
        let testCases: [(name: String, emoji: String, description: String)] = [
            ("Coffee Shop", "☕️", "Coffee shop"),
            ("Pizza Place", "🍕", "Pizza place"),
            ("Hotel", "🏨", "Hotel"),
            ("Park", "🏞️", "Park"),
            ("Museum", "🏛️", "Museum"),
            ("Theater", "🎭", "Theater"),
            ("Store", "🏪", "Store")
        ]
        
        for testCase in testCases {
            let addOns = MapItemSuggestions(
                name: testCase.name,
                notes: testCase.description,
                symbol: testCase.emoji
            )
            
            #expect(addOns.name == testCase.name, "Name should be \(testCase.name)")
            #expect(addOns.symbol == testCase.emoji, "Symbol should be \(testCase.emoji)")
            #expect(addOns.notes == testCase.description, "Notes should be \(testCase.description)")
        }
    }
    
    // MARK: - MKMapItem addOns Integration Tests
    
    @Test("addOns returns valid LocationAddOns for named location with address")
    func testAddOnsForNamedLocationWithAddress() async throws {
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let mapItem = Self.createTestMapItem(
            coordinate: coordinate,
            name: "Blue Bottle Coffee",
            addressComponents: [
                CNPostalAddressStreetKey: "66 Mint St",
                CNPostalAddressCityKey: "San Francisco",
                CNPostalAddressStateKey: "CA",
                CNPostalAddressPostalCodeKey: "94103"
            ]
        )
        
        // This test requires the actual FoundationModels framework to be available
        // and will make a real call to the language model
        let addOns = try await mapItem.suggestions
        
        // Verify the structure is correct
        #expect(!addOns.name.isEmpty, "Name should not be empty")
        #expect(!addOns.notes.isEmpty, "Notes should not be empty")
        #expect(!addOns.symbol.isEmpty, "Symbol should not be empty")
        #expect(addOns.notes.count >= 10, "Notes should be a meaningful description (at least 10 characters)")
        
        // Symbol should be a single emoji (typically 1-2 characters due to unicode)
        #expect(addOns.symbol.count <= 4, "Symbol should be a single emoji")
    }
    
    @Test("addOns returns valid LocationAddOns for museum")
    func testAddOnsForMuseum() async throws {
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let mapItem = Self.createTestMapItem(
            coordinate: coordinate,
            name: "California Academy of Sciences",
            addressComponents: [
                CNPostalAddressStreetKey: "55 Music Concourse Dr",
                CNPostalAddressCityKey: "San Francisco",
                CNPostalAddressStateKey: "CA",
                CNPostalAddressPostalCodeKey: "94118"
            ]
        )
        
        let addOns = try await mapItem.suggestions
        
        // Verify basic structure
        #expect(!addOns.name.isEmpty, "Name should not be empty")
        #expect(!addOns.notes.isEmpty, "Notes should not be empty")
        #expect(!addOns.symbol.isEmpty, "Symbol should not be empty")
        
        // The notes should be 1-3 sentences as per the @Guide
        let sentences = addOns.notes.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        #expect(sentences.count >= 1 && sentences.count <= 3, 
                "Notes should be 1-3 sentences, got \(sentences.count)")
    }
    
    @Test("addOns returns valid LocationAddOns for restaurant")
    func testAddOnsForRestaurant() async throws {
        let coordinate = CLLocationCoordinate2D(latitude: 37.8044, longitude: -122.2712)
        let mapItem = Self.createTestMapItem(
            coordinate: coordinate,
            name: "Chez Panisse",
            addressComponents: [
                CNPostalAddressStreetKey: "1517 Shattuck Ave",
                CNPostalAddressCityKey: "Berkeley",
                CNPostalAddressStateKey: "CA",
                CNPostalAddressPostalCodeKey: "94709"
            ]
        )
        
        let addOns = try await mapItem.suggestions
        
        #expect(!addOns.name.isEmpty, "Name should not be empty")
        #expect(!addOns.notes.isEmpty, "Notes should not be empty")
        #expect(!addOns.symbol.isEmpty, "Symbol should not be empty")
    }
    
    @Test("addOns handles location without name")
    func testAddOnsForUnnamedLocation() async throws {
        let coordinate = CLLocationCoordinate2D(latitude: 37.3861, longitude: -122.0839)
        let mapItem = Self.createTestMapItem(
            coordinate: coordinate,
            addressComponents: [
                CNPostalAddressStreetKey: "1 Apple Park Way",
                CNPostalAddressCityKey: "Cupertino",
                CNPostalAddressStateKey: "CA",
                CNPostalAddressPostalCodeKey: "95014"
            ]
        )
        
        // Should still generate add-ons even without a name
        let addOns = try await mapItem.suggestions
        
        #expect(!addOns.name.isEmpty, "Name should be generated even without an original name")
        #expect(!addOns.notes.isEmpty, "Notes should be generated even without a name")
        #expect(!addOns.symbol.isEmpty, "Symbol should be generated even without a name")
    }
    
    @Test("addOns handles location with only coordinates")
    func testAddOnsForCoordinatesOnly() async throws {
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let mapItem = Self.createTestMapItem(coordinate: coordinate)
        
        // Should generate add-ons based on coordinates and generic location description
        let addOns = try await mapItem.suggestions
        
        #expect(!addOns.name.isEmpty, "Name should be generated for coordinate-only location")
        #expect(!addOns.notes.isEmpty, "Notes should be generated for coordinate-only location")
        #expect(!addOns.symbol.isEmpty, "Symbol should be generated for coordinate-only location")
    }
    
    // MARK: - Error Handling Tests
    
    @Test("addOns handles edge case with zero coordinates")
    func testAddOnsWithZeroCoordinates() async throws {
        let coordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        let mapItem = Self.createTestMapItem(
            coordinate: coordinate,
            name: "Null Island"
        )
        
        // Should still attempt to generate add-ons
        let addOns = try await mapItem.suggestions
        
        #expect(!addOns.name.isEmpty, "Should generate name even for unusual coordinates")
        #expect(!addOns.notes.isEmpty, "Should generate notes even for unusual coordinates")
        #expect(!addOns.symbol.isEmpty, "Should generate symbol even for unusual coordinates")
    }
    
    // MARK: - Concurrency Tests
    
    @Test("addOns can handle concurrent requests")
    func testConcurrentAddOnsRequests() async throws {
        let mapItems = [
            Self.createTestMapItem(
                coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                name: "Location 1"
            ),
            Self.createTestMapItem(
                coordinate: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4294),
                name: "Location 2"
            ),
            Self.createTestMapItem(
                coordinate: CLLocationCoordinate2D(latitude: 37.7949, longitude: -122.4394),
                name: "Location 3"
            )
        ]
        
        // Make concurrent requests
        let results = try await withThrowingTaskGroup(of: MapItemSuggestions.self) { group in
            for mapItem in mapItems {
                group.addTask {
                    try await mapItem.suggestions
                }
            }
            
            var addOnsArray: [MapItemSuggestions] = []
            for try await result in group {
                addOnsArray.append(result)
            }
            return addOnsArray
        }
        
        // All requests should complete successfully
        #expect(results.count == 3, "All concurrent requests should complete")
        for addOn in results {
            #expect(!addOn.name.isEmpty, "Each result should have a name")
            #expect(!addOn.notes.isEmpty, "Each result should have notes")
            #expect(!addOn.symbol.isEmpty, "Each result should have a symbol")
        }
    }
    
    // MARK: - Property Validation Tests
    
    @Test("addOns name should be brief (1-3 words)")
    func testAddOnsNameIsBrief() async throws {
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let mapItem = Self.createTestMapItem(
            coordinate: coordinate,
            name: "Ferry Building Marketplace"
        )
        
        let addOns = try await mapItem.suggestions
        
        // Name should be 1-3 words as specified in the @Guide
        let words = addOns.name.components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
        
        #expect(words.count >= 1, "Should have at least 1 word")
        #expect(words.count <= 3, "Should have at most 3 words, got \(words.count)")
        #expect(!addOns.name.isEmpty, "Name should not be empty")
    }
    
    @Test("addOns notes should be concise (1-3 sentences)")
    func testAddOnsNotesAreConcise() async throws {
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let mapItem = Self.createTestMapItem(
            coordinate: coordinate,
            name: "Ferry Building Marketplace"
        )
        
        let addOns = try await mapItem.suggestions
        
        // Notes should be 1-3 sentences as specified in the @Guide
        let sentences = addOns.notes.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        #expect(sentences.count >= 1, "Should have at least 1 sentence")
        #expect(sentences.count <= 3, "Should have at most 3 sentences, got \(sentences.count)")
    }
    
    @Test("addOns symbol should be a single emoji")
    func testAddOnsSymbolIsSingleEmoji() async throws {
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let mapItem = Self.createTestMapItem(
            coordinate: coordinate,
            name: "Starbucks Reserve Roastery"
        )
        
        let addOns = try await mapItem.suggestions
        
        // Symbol should be a single emoji (might be 1-4 characters due to unicode modifiers)
        #expect(addOns.symbol.count >= 1, "Symbol should not be empty")
        #expect(addOns.symbol.count <= 4, "Symbol should be a single emoji (allowing for unicode modifiers)")
        
        // Should not be plain text
        #expect(!addOns.symbol.contains(where: { $0.isLetter && $0.isASCII }), 
                "Symbol should be emoji, not ASCII letters")
    }
    
}
