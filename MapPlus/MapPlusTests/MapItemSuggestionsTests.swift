//
//  MapItemSuggestionsTests.swift
//  MapPlusTests
//
//  Created by Patrick McGonigle on 6/5/26.
//

import Testing
import MapKit
@testable import MapPlus

@Suite("MapItemSuggestions Tests")
struct MapItemSuggestionsTests {
    
    // MARK: - Test Cases
    
    struct MapItemTestCase {
        let name: String
        let latitude: Double
        let longitude: Double
        let expectedSymbol: String
        let description: String
    }
    
    struct CustomSuggestionsTestCase {
        let mapItemName: String
        let customSuggestions: MapItemSuggestions
        let description: String
    }
    
    // MARK: - Helper Methods
    
    /// Creates a mock MKMapItem for testing
    private func createMockMapItem(
        name: String,
        latitude: Double,
        longitude: Double
    ) -> MKMapItem {
        let coordinate = CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        return mapItem
    }
    
    // MARK: - MockMapItemSuggestionsService Tests
    
    @Test("Mock suggestions service generates default suggestions", arguments: [
        MapItemTestCase(
            name: "Central Park",
            latitude: 40.7829,
            longitude: -73.9654,
            expectedSymbol: "🌳",
            description: "Park location"
        ),
        MapItemTestCase(
            name: "Golden Gate Bridge",
            latitude: 37.8199,
            longitude: -122.4783,
            expectedSymbol: "🌉",
            description: "Bridge landmark"
        ),
        MapItemTestCase(
            name: "Apple Park",
            latitude: 37.3349,
            longitude: -122.0090,
            expectedSymbol: "🍎",
            description: "Apple campus"
        ),
        MapItemTestCase(
            name: "Cafe Milano",
            latitude: 38.9072,
            longitude: -77.0369,
            expectedSymbol: "🍽️",
            description: "Restaurant/cafe"
        ),
        MapItemTestCase(
            name: "Beach Hotel",
            latitude: 33.7701,
            longitude: -118.1937,
            expectedSymbol: "🏨",
            description: "Hotel (should match hotel before beach)"
        ),
        MapItemTestCase(
            name: "JFK Airport",
            latitude: 40.6413,
            longitude: -73.7781,
            expectedSymbol: "✈️",
            description: "Airport"
        ),
        MapItemTestCase(
            name: "Malibu Beach",
            latitude: 34.0259,
            longitude: -118.7798,
            expectedSymbol: "🏖️",
            description: "Beach location"
        ),
        MapItemTestCase(
            name: "Natural History Museum",
            latitude: 40.7813,
            longitude: -73.9740,
            expectedSymbol: "🏛️",
            description: "Museum"
        ),
        MapItemTestCase(
            name: "Harvard University",
            latitude: 42.3770,
            longitude: -71.1167,
            expectedSymbol: "🎓",
            description: "University"
        ),
        MapItemTestCase(
            name: "City Hospital",
            latitude: 40.7589,
            longitude: -73.9851,
            expectedSymbol: "🏥",
            description: "Hospital"
        ),
        MapItemTestCase(
            name: "Public Library",
            latitude: 40.7532,
            longitude: -73.9822,
            expectedSymbol: "📚",
            description: "Library"
        ),
        MapItemTestCase(
            name: "Yankee Stadium",
            latitude: 40.8296,
            longitude: -73.9262,
            expectedSymbol: "🏟️",
            description: "Stadium"
        ),
        MapItemTestCase(
            name: "Random Location",
            latitude: 0.0,
            longitude: 0.0,
            expectedSymbol: "📍",
            description: "Generic location"
        )
    ])
    func testMockServiceGeneratesDefaultSuggestions(testCase: MapItemTestCase) async throws {
        let mapItem = createMockMapItem(
            name: testCase.name,
            latitude: testCase.latitude,
            longitude: testCase.longitude
        )
        let service = MockMapItemSuggestionsService()
        
        let suggestions = try await service.suggestions(for: mapItem)
        
        #expect(suggestions.name == testCase.name,
                "Expected name '\(testCase.name)' for \(testCase.description)")
        #expect(suggestions.symbol == testCase.expectedSymbol,
                "Expected symbol '\(testCase.expectedSymbol)' for \(testCase.description)")
        #expect(suggestions.notes.contains(testCase.name),
                "Expected notes to contain '\(testCase.name)' for \(testCase.description)")
    }
    
    @Test("Mock suggestions service handles unnamed locations")
    func testMockServiceHandlesUnnamedLocation() async throws {
        let mapItem = createMockMapItem(
            name: "",
            latitude: 37.7749,
            longitude: -122.4194
        )
        mapItem.name = nil // Explicitly set to nil
        let service = MockMapItemSuggestionsService()
        
        let suggestions = try await service.suggestions(for: mapItem)
        
        #expect(suggestions.name == "Unknown Location",
                "Expected 'Unknown Location' for unnamed map item")
        #expect(suggestions.symbol == "📍",
                "Expected default symbol for unnamed location")
        #expect(suggestions.notes.contains("Unknown Location"),
                "Expected notes to contain 'Unknown Location'")
    }
    
    @Test("Mock suggestions service uses custom suggestions", arguments: [
        CustomSuggestionsTestCase(
            mapItemName: "Test Location",
            customSuggestions: MapItemSuggestions(
                name: "Custom Name",
                notes: "Custom notes for testing",
                symbol: "🎯"
            ),
            description: "Basic custom suggestions"
        ),
        CustomSuggestionsTestCase(
            mapItemName: "Apple Park",
            customSuggestions: MapItemSuggestions(
                name: "Apple Campus",
                notes: "The main Apple headquarters in Cupertino",
                symbol: "🏢"
            ),
            description: "Custom suggestions override defaults"
        ),
        CustomSuggestionsTestCase(
            mapItemName: "Central Park",
            customSuggestions: MapItemSuggestions(
                name: "NYC Park",
                notes: "A large urban park in Manhattan",
                symbol: "🌲"
            ),
            description: "Custom park suggestions"
        )
    ])
    func testMockServiceUsesCustomSuggestions(testCase: CustomSuggestionsTestCase) async throws {
        let mapItem = createMockMapItem(
            name: testCase.mapItemName,
            latitude: 37.7749,
            longitude: -122.4194
        )
        let service = MockMapItemSuggestionsService(
            mockSuggestions: testCase.customSuggestions
        )
        
        let suggestions = try await service.suggestions(for: mapItem)
        
        #expect(suggestions.name == testCase.customSuggestions.name,
                "Expected custom name '\(testCase.customSuggestions.name)' for \(testCase.description)")
        #expect(suggestions.notes == testCase.customSuggestions.notes,
                "Expected custom notes for \(testCase.description)")
        #expect(suggestions.symbol == testCase.customSuggestions.symbol,
                "Expected custom symbol '\(testCase.customSuggestions.symbol)' for \(testCase.description)")
    }
    
    // MARK: - Error Handling Tests
    
    struct ErrorTestCase {
        let mapItemName: String
        let description: String
    }
    
    @Test("Mock suggestions service handles failures", arguments: [
        ErrorTestCase(
            mapItemName: "Test Location",
            description: "Named location fails"
        ),
        ErrorTestCase(
            mapItemName: "Apple Park",
            description: "Known location fails"
        ),
        ErrorTestCase(
            mapItemName: "",
            description: "Empty name fails"
        )
    ])
    func testMockServiceHandlesFailure(testCase: ErrorTestCase) async throws {
        let mapItem = createMockMapItem(
            name: testCase.mapItemName,
            latitude: 37.7749,
            longitude: -122.4194
        )
        let service = MockMapItemSuggestionsService(shouldSucceed: false)
        
        do {
            _ = try await service.suggestions(for: mapItem)
            Issue.record("Expected suggestions to throw for \(testCase.description), but it did not")
        } catch let error as MapPlusError {
            #expect(error == .noAddressFound,
                    "Expected .noAddressFound for \(testCase.description)")
        } catch {
            Issue.record("Expected MapPlusError for \(testCase.description), but got: \(error)")
        }
    }
    
    // MARK: - Protocol Interface Tests
    
    @Test("Protocol interface with AIMapItemSuggestionsService")
    func testProtocolInterfaceWithAIService() async throws {
        let mapItem = createMockMapItem(
            name: "Test Location",
            latitude: 37.7749,
            longitude: -122.4194
        )
        let service: MapItemSuggestionsService = AIMapItemSuggestionsService()
        
        // This test verifies we can use AIMapItemSuggestionsService through the protocol
        // We expect it to fail in test environment without FoundationModels access
        do {
            _ = try await service.suggestions(for: mapItem)
        } catch {
            // Expected to fail in test environment without AI
        }
    }
    
    struct ProtocolTestCase {
        let mapItemName: String
        let expectedSymbol: String
        let description: String
    }
    
    @Test("Protocol interface with MockService", arguments: [
        ProtocolTestCase(
            mapItemName: "Central Park",
            expectedSymbol: "🌳",
            description: "Park through protocol"
        ),
        ProtocolTestCase(
            mapItemName: "Golden Gate Bridge",
            expectedSymbol: "🌉",
            description: "Bridge through protocol"
        ),
        ProtocolTestCase(
            mapItemName: "Apple Campus",
            expectedSymbol: "🍎",
            description: "Apple location through protocol"
        )
    ])
    func testProtocolInterfaceWithMockService(testCase: ProtocolTestCase) async throws {
        let mapItem = createMockMapItem(
            name: testCase.mapItemName,
            latitude: 37.7749,
            longitude: -122.4194
        )
        let service: MapItemSuggestionsService = MockMapItemSuggestionsService()
        
        let suggestions = try await service.suggestions(for: mapItem)
        
        #expect(suggestions.name == testCase.mapItemName,
                "Expected name '\(testCase.mapItemName)' for \(testCase.description)")
        #expect(suggestions.symbol == testCase.expectedSymbol,
                "Expected symbol '\(testCase.expectedSymbol)' for \(testCase.description)")
    }
    
    // MARK: - Symbol Heuristics Tests
    
    struct SymbolHeuristicTestCase {
        let name: String
        let expectedSymbol: String
        let description: String
    }
    
    @Test("Symbol heuristics work correctly", arguments: [
        SymbolHeuristicTestCase(
            name: "Central Park NYC",
            expectedSymbol: "🌳",
            description: "Park keyword detected"
        ),
        SymbolHeuristicTestCase(
            name: "Brooklyn Bridge",
            expectedSymbol: "🌉",
            description: "Bridge keyword detected"
        ),
        SymbolHeuristicTestCase(
            name: "Apple Store",
            expectedSymbol: "🍎",
            description: "Apple keyword detected"
        ),
        SymbolHeuristicTestCase(
            name: "Italian Restaurant",
            expectedSymbol: "🍽️",
            description: "Restaurant keyword detected"
        ),
        SymbolHeuristicTestCase(
            name: "Starbucks Cafe",
            expectedSymbol: "🍽️",
            description: "Cafe keyword detected"
        ),
        SymbolHeuristicTestCase(
            name: "Marriott Hotel Downtown",
            expectedSymbol: "🏨",
            description: "Hotel keyword detected"
        ),
        SymbolHeuristicTestCase(
            name: "LAX International Airport",
            expectedSymbol: "✈️",
            description: "Airport keyword detected"
        ),
        SymbolHeuristicTestCase(
            name: "Santa Monica Beach",
            expectedSymbol: "🏖️",
            description: "Beach keyword detected"
        ),
        SymbolHeuristicTestCase(
            name: "Art Museum",
            expectedSymbol: "🏛️",
            description: "Museum keyword detected"
        ),
        SymbolHeuristicTestCase(
            name: "Stanford University",
            expectedSymbol: "🎓",
            description: "University keyword detected"
        ),
        SymbolHeuristicTestCase(
            name: "Medical School",
            expectedSymbol: "🎓",
            description: "School keyword detected"
        ),
        SymbolHeuristicTestCase(
            name: "General Hospital",
            expectedSymbol: "🏥",
            description: "Hospital keyword detected"
        ),
        SymbolHeuristicTestCase(
            name: "City Library",
            expectedSymbol: "📚",
            description: "Library keyword detected"
        ),
        SymbolHeuristicTestCase(
            name: "Sports Stadium",
            expectedSymbol: "🏟️",
            description: "Stadium keyword detected"
        ),
        SymbolHeuristicTestCase(
            name: "Basketball Arena",
            expectedSymbol: "🏟️",
            description: "Arena keyword detected"
        ),
        SymbolHeuristicTestCase(
            name: "Some Random Place",
            expectedSymbol: "📍",
            description: "Default symbol for unknown type"
        )
    ])
    func testSymbolHeuristics(testCase: SymbolHeuristicTestCase) async throws {
        let mapItem = createMockMapItem(
            name: testCase.name,
            latitude: 37.7749,
            longitude: -122.4194
        )
        let service = MockMapItemSuggestionsService()
        
        let suggestions = try await service.suggestions(for: mapItem)
        
        #expect(suggestions.symbol == testCase.expectedSymbol,
                "Expected symbol '\(testCase.expectedSymbol)' for \(testCase.description)")
    }
    
    // MARK: - Multiple Map Items Tests
    
    @Test("Mock service handles multiple map items sequentially")
    func testMultipleMapItemsSequentially() async throws {
        let service = MockMapItemSuggestionsService()
        
        let park = createMockMapItem(name: "Central Park", latitude: 40.7829, longitude: -73.9654)
        let bridge = createMockMapItem(name: "Golden Gate Bridge", latitude: 37.8199, longitude: -122.4783)
        let airport = createMockMapItem(name: "SFO Airport", latitude: 37.6213, longitude: -122.3790)
        
        let parkSuggestions = try await service.suggestions(for: park)
        let bridgeSuggestions = try await service.suggestions(for: bridge)
        let airportSuggestions = try await service.suggestions(for: airport)
        
        #expect(parkSuggestions.symbol == "🌳", "Expected park symbol")
        #expect(bridgeSuggestions.symbol == "🌉", "Expected bridge symbol")
        #expect(airportSuggestions.symbol == "✈️", "Expected airport symbol")
    }
    
    // MARK: - MapItemSuggestions Structure Tests
    
    @Test("MapItemSuggestions can be created with all fields")
    func testMapItemSuggestionsCreation() {
        let suggestions = MapItemSuggestions(
            name: "Test Location",
            notes: "These are test notes",
            symbol: "🎯"
        )
        
        #expect(suggestions.name == "Test Location", "Expected name to match")
        #expect(suggestions.notes == "These are test notes", "Expected notes to match")
        #expect(suggestions.symbol == "🎯", "Expected symbol to match")
    }
    
    @Test("MapItemSuggestions supports various emoji symbols", arguments: [
        "🍎", "🌳", "🌉", "📍", "🏨", "✈️", "🏖️", "🏛️", "🎓", "🏥", "📚", "🏟️", "🍽️"
    ])
    func testMapItemSuggestionsSupportsEmojis(emoji: String) {
        let suggestions = MapItemSuggestions(
            name: "Test",
            notes: "Test notes",
            symbol: emoji
        )
        
        #expect(suggestions.symbol == emoji, "Expected symbol '\(emoji)' to be preserved")
    }
}
