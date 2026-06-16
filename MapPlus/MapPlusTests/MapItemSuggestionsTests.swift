//
//  MapItemSuggestionsTests.swift
//  MapPlusTests
//
//  Created by Patrick McGonigle on 6/5/26.
//

import Testing
import MapKit
@testable import MapPlus

@Suite("MapItemsIterator Tests")
struct MapItemsIteratorTests {
    
    // MARK: - Helper Methods
    
    /// Creates a sample MKMapItem for testing
    private func makeSampleMapItem(
        name: String,
        latitude: Double,
        longitude: Double
    ) -> MKMapItem {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        return mapItem
    }
    
    // MARK: - Tests
    
    @Test("Iterator returns nil for empty array")
    func testEmptyArray() async throws {
        let service = BasicMapItemSuggestionService()
        var iterator = MapItemsExplorer(
            suggestionService: service,
            pointOfInterestService: MockPointOfInterestService(),
            mapItems: []
        )
        
        let locationInfo = await iterator.nextMapItem()
        #expect(locationInfo == nil)
    }
    
    @Test("Iterator returns LocationInfo for single map item")
    func testSingleMapItem() async throws {
        let service = BasicMapItemSuggestionService()
        let mapItem = makeSampleMapItem(
            name: "Golden Gate Bridge",
            latitude: 37.8199,
            longitude: -122.4783
        )
        var iterator = MapItemsExplorer(
            suggestionService: service,
            pointOfInterestService: MockPointOfInterestService(),
            mapItems: [mapItem]
        )
        
        let locationInfo = await iterator.nextMapItem()
        
        #expect(locationInfo != nil)
        #expect(locationInfo?.briefDescription == "Golden Gate Bridge")
        #expect(locationInfo?.coordinates.latitude == 37.8199)
        #expect(locationInfo?.coordinates.longitude == -122.4783)
        #expect(locationInfo?.suggestedSymbol == "📍")
        #expect(locationInfo?.suggestedNotes == "")
    }
    
    @Test("Iterator processes multiple map items sequentially")
    func testMultipleMapItems() async throws {
        let service = BasicMapItemSuggestionService()
        let mapItem1 = makeSampleMapItem(
            name: "Statue of Liberty",
            latitude: 40.6892,
            longitude: -74.0445
        )
        let mapItem2 = makeSampleMapItem(
            name: "Empire State Building",
            latitude: 40.7484,
            longitude: -73.9857
        )
        let mapItem3 = makeSampleMapItem(
            name: "Central Park",
            latitude: 40.7829,
            longitude: -73.9654
        )
        
        var iterator = MapItemsExplorer(
            suggestionService: service,
            pointOfInterestService: MockPointOfInterestService(),
            mapItems: [mapItem1, mapItem2, mapItem3]
        )
        
        // First item
        let location1 = await iterator.nextMapItem()
        #expect(location1?.coordinates.latitude == 40.6892)
        #expect(location1?.coordinates.longitude == -74.0445)
        
        // Second item
        let location2 = await iterator.nextMapItem()
        #expect(location2?.coordinates.latitude == 40.7484)
        #expect(location2?.coordinates.longitude == -73.9857)
        
        // Third item
        let location3 = await iterator.nextMapItem()
        #expect(location3?.coordinates.latitude == 40.7829)
        #expect(location3?.coordinates.longitude == -73.9654)
        
        // No more items
        let location4 = await iterator.nextMapItem()
        #expect(location4 == nil)
    }
    
    @Test("Iterator uses default suggestions from BasicMapItemSuggestionService")
    func testBasicMapItemSuggestionServiceDefaults() async throws {
        let service = BasicMapItemSuggestionService()
        let mapItem = makeSampleMapItem(
            name: "Test Location",
            latitude: 0.0,
            longitude: 0.0
        )
        var iterator = MapItemsExplorer(
            suggestionService: service,
            pointOfInterestService: MockPointOfInterestService(),
            mapItems: [mapItem]
        )
        
        let locationInfo = await iterator.nextMapItem()
        
        // BasicMapItemSuggestionService should provide default values
        #expect(locationInfo?.suggestedSymbol == "📍")
        #expect(locationInfo?.suggestedNotes == "")
    }
    
    @Test("Iterator handles map item without name")
    func testMapItemWithoutName() async throws {
        let service = BasicMapItemSuggestionService()
        let coordinate = CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        // Note: not setting mapItem.name
        
        var iterator = MapItemsExplorer(
            suggestionService: service,
            pointOfInterestService: MockPointOfInterestService(),
            mapItems: [mapItem]
        )
        
        let locationInfo = await iterator.nextMapItem()
        
        #expect(locationInfo != nil)
        // When name is nil, BasicMapItemSuggestionService returns empty string for name
        #expect(locationInfo?.coordinates.latitude == 34.0522)
        #expect(locationInfo?.coordinates.longitude == -118.2437)
    }
    
    @Test("Iterator maintains state across multiple calls")
    func testIteratorState() async throws {
        let service = BasicMapItemSuggestionService()
        let mapItems = [
            makeSampleMapItem(name: "Location A", latitude: 10.0, longitude: 20.0),
            makeSampleMapItem(name: "Location B", latitude: 30.0, longitude: 40.0),
        ]
        
        var iterator = MapItemsExplorer(
            suggestionService: service,
            pointOfInterestService: MockPointOfInterestService(),
            mapItems: mapItems
        )
        
        // First call should return first item
        let first = await iterator.nextMapItem()
        #expect(first?.briefDescription == "Location A")
        
        // Second call should return second item (not first again)
        let second = await iterator.nextMapItem()
        #expect(second?.briefDescription == "Location B")
    }
    
    @Test("Iterator with different coordinates")
    func testDifferentCoordinates() async throws {
        let service = BasicMapItemSuggestionService()
        
        // Test with various coordinate values
        let testCases: [(String, Double, Double)] = [
            ("Equator", 0.0, 0.0),
            ("North Pole", 90.0, 0.0),
            ("South Pole", -90.0, 0.0),
            ("International Date Line", 0.0, 180.0),
            ("Prime Meridian", 51.4778, 0.0)
        ]
        
        for (name, lat, lon) in testCases {
            let mapItem = makeSampleMapItem(name: name, latitude: lat, longitude: lon)
            var iterator = MapItemsExplorer(
                suggestionService: service,
                pointOfInterestService: MockPointOfInterestService(),
                mapItems: [mapItem]
            )
            
            let locationInfo = await iterator.nextMapItem()
            
            #expect(locationInfo?.briefDescription == name)
            #expect(locationInfo?.coordinates.latitude == lat)
            #expect(locationInfo?.coordinates.longitude == lon)
        }
    }
    
}
