// Thanks, Claude Sonnet

import Testing
@testable import MapPlus

struct AddressLookupTests {
    
    // MARK: - MockAddressLookupService Tests
    
    // Test data for parameterized address lookup tests
    struct AddressLookupTestCase {
        let query: String
        let expectedName: String
        let expectedLatitude: Double
        let expectedLongitude: Double
        let description: String
    }
    
    @Test("Mock address lookup success cases", arguments: [
        AddressLookupTestCase(
            query: "San Francisco",
            expectedName: "San Francisco",
            expectedLatitude: 37.7749,
            expectedLongitude: -122.4194,
            description: "Exact match"
        ),
        AddressLookupTestCase(
            query: "san francisco",
            expectedName: "San Francisco",
            expectedLatitude: 37.7749,
            expectedLongitude: -122.4194,
            description: "Case insensitive match"
        ),
        AddressLookupTestCase(
            query: "Francisco",
            expectedName: "San Francisco",
            expectedLatitude: 37.7749,
            expectedLongitude: -122.4194,
            description: "Partial match"
        ),
        AddressLookupTestCase(
            query: "New York",
            expectedName: "NYC",
            expectedLatitude: 40.7128,
            expectedLongitude: -74.0060,
            description: "New York exact match"
        ),
        AddressLookupTestCase(
            query: "London",
            expectedName: "London",
            expectedLatitude: 51.5074,
            expectedLongitude: -0.1278,
            description: "London exact match"
        ),
        AddressLookupTestCase(
            query: "Tokyo",
            expectedName: "Tokyo",
            expectedLatitude: 35.6762,
            expectedLongitude: 139.6503,
            description: "Tokyo exact match"
        ),
        AddressLookupTestCase(
            query: "1 Infinite Loop",
            expectedName: "Apple HQ",
            expectedLatitude: 37.3349,
            expectedLongitude: -122.0090,
            description: "Apple headquarters exact match"
        )
    ])
    func testMockAddressLookupSuccess(testCase: AddressLookupTestCase) async throws {
        let service = MockAddressLookupService()
        
        let mapItems = try await service.mapItemsFor(searchString: testCase.query)
        
        #expect(!mapItems.isEmpty, "Expected at least one map item for \(testCase.description)")
        
        let firstItem = mapItems[0]
        #expect(firstItem.name == testCase.expectedName,
                "Expected name '\(testCase.expectedName)' for \(testCase.description)")
        #expect(firstItem.placemark.coordinate.latitude == testCase.expectedLatitude,
                "Expected latitude \(testCase.expectedLatitude) for \(testCase.description)")
        #expect(firstItem.placemark.coordinate.longitude == testCase.expectedLongitude,
                "Expected longitude \(testCase.expectedLongitude) for \(testCase.description)")
    }
    
    // Test data for custom address lookup tests
    struct CustomAddressTestCase {
        let customAddress: LocationInfo
        let queryAddress: String
        let description: String
    }
    
    @Test("Mock address lookup with custom address", arguments: [
        CustomAddressTestCase(
            customAddress: LocationInfo(
                briefDescription: "Custom",
                fullDescription: "Custom Location",
                latitude: 12.34,
                longitude: 56.78
            ),
            queryAddress: "Any Address",
            description: "Basic custom address"
        ),
        CustomAddressTestCase(
            customAddress: LocationInfo(
                briefDescription: "HQ",
                fullDescription: "Test Headquarters",
                latitude: 40.7589,
                longitude: -73.9851
            ),
            queryAddress: "Times Square",
            description: "Custom address overrides known location"
        ),
        CustomAddressTestCase(
            customAddress: LocationInfo(
                briefDescription: "Special",
                fullDescription: "Special Test Location",
                latitude: -33.8688,
                longitude: 151.2093
            ),
            queryAddress: "Sydney Opera House",
            description: "Custom address for different query"
        )
    ])
    func testMockAddressLookupSuccessWithCustomAddress(testCase: CustomAddressTestCase) async throws {
        let service = MockAddressLookupService(customAddress: testCase.customAddress)
        
        let mapItems = try await service.mapItemsFor(searchString: testCase.queryAddress)
        
        #expect(!mapItems.isEmpty, "Expected at least one map item for \(testCase.description)")
        
        let firstItem = mapItems[0]
        #expect(firstItem.name == testCase.customAddress.briefDescription,
                "Expected name '\(testCase.customAddress.briefDescription)' for \(testCase.description)")
        #expect(firstItem.placemark.coordinate.latitude == testCase.customAddress.coordinates.latitude,
                "Expected latitude \(testCase.customAddress.coordinates.latitude) for \(testCase.description)")
        #expect(firstItem.placemark.coordinate.longitude == testCase.customAddress.coordinates.longitude,
                "Expected longitude \(testCase.customAddress.coordinates.longitude) for \(testCase.description)")
    }
    
    // Test data for generic result tests (unknown addresses)
    struct GenericResultTestCase {
        let query: String
        let expectedName: String
        let description: String
    }
    
    @Test("Mock address lookup with generic results", arguments: [
        GenericResultTestCase(
            query: "Unknown Place",
            expectedName: "Mock address",
            description: "Unknown place returns mock result"
        ),
        GenericResultTestCase(
            query: "Atlantis",
            expectedName: "Mock address",
            description: "Fictional location returns mock result"
        ),
        GenericResultTestCase(
            query: "Nowhere City",
            expectedName: "Mock address",
            description: "Non-existent city returns mock result"
        ),
        GenericResultTestCase(
            query: "Random Address 123",
            expectedName: "Mock address",
            description: "Random address returns mock result"
        )
    ])
    func testMockAddressLookupSuccessWithGenericResult(testCase: GenericResultTestCase) async throws {
        let service = MockAddressLookupService()
        
        let mapItems = try await service.mapItemsFor(searchString: testCase.query)
        
        #expect(!mapItems.isEmpty, "Expected at least one map item for \(testCase.description)")
        
        let firstItem = mapItems[0]
        #expect(firstItem.name == testCase.expectedName,
                "Expected name '\(testCase.expectedName)' for \(testCase.description)")
        #expect(firstItem.placemark.coordinate.latitude == 37.7749,
                "Expected default latitude for \(testCase.description)")
        #expect(firstItem.placemark.coordinate.longitude == -122.4194,
                "Expected default longitude for \(testCase.description)")
    }
    
    // Test data for failure cases
    struct FailureTestCase {
        let queryAddress: String
        let description: String
    }
    
    @Test("Mock address lookup failure", arguments: [
        FailureTestCase(
            queryAddress: "Any Address",
            description: "Generic address query fails"
        ),
        FailureTestCase(
            queryAddress: "San Francisco",
            description: "Known address query fails when service fails"
        ),
        FailureTestCase(
            queryAddress: "London",
            description: "Another known address fails when service fails"
        ),
        FailureTestCase(
            queryAddress: "",
            description: "Empty address query fails"
        )
    ])
    func testMockAddressLookupFailure(testCase: FailureTestCase) async throws {
        let service = MockAddressLookupService(shouldSucceed: false)
        
        do {
            _ = try await service.mapItemsFor(searchString: testCase.queryAddress)
            Issue.record("Expected mapItemsFor to throw for \(testCase.description), but it did not")
        } catch let error as MapPlusError {
            #expect(error == .noAddressFound, "Expected .noAddressFound for \(testCase.description)")
        } catch {
            Issue.record("Expected MapPlusError.noAddressFound for \(testCase.description), but got: \(error)")
        }
    }
    
    // MARK: - Protocol Interface Tests
    
    // Test data for protocol interface with mock service
    struct ProtocolInterfaceTestCase {
        let queryAddress: String
        let expectedName: String
        let expectedLatitude: Double
        let expectedLongitude: Double
        let description: String
    }
    
    @Test("Protocol interface with MapKitService")
    func testProtocolInterfaceWithMapKitService() async throws {
        let service: AddressLookupService = MapKitAddressLookupService()
        
        // This test verifies we can use MapKitAddressLookupService through the protocol interface
        // We expect it to fail in a sandboxed test environment without MapKit access
        do {
            _ = try await service.mapItemsFor(searchString: "Test Address")
        } catch {
            // Expected to fail in test environment
        }
    }
    
    @Test("Protocol interface with MockService", arguments: [
        ProtocolInterfaceTestCase(
            queryAddress: "San Francisco",
            expectedName: "San Francisco",
            expectedLatitude: 37.7749,
            expectedLongitude: -122.4194,
            description: "San Francisco through protocol"
        ),
        ProtocolInterfaceTestCase(
            queryAddress: "New York",
            expectedName: "NYC",
            expectedLatitude: 40.7128,
            expectedLongitude: -74.0060,
            description: "New York through protocol"
        ),
        ProtocolInterfaceTestCase(
            queryAddress: "Tokyo",
            expectedName: "Tokyo",
            expectedLatitude: 35.6762,
            expectedLongitude: 139.6503,
            description: "Tokyo through protocol"
        )
    ])
    func testProtocolInterfaceWithMockService(testCase: ProtocolInterfaceTestCase) async throws {
        let service: AddressLookupService = MockAddressLookupService()
        
        // This test verifies we can use MockAddressLookupService through the protocol interface
        let mapItems = try await service.mapItemsFor(searchString: testCase.queryAddress)
        
        #expect(!mapItems.isEmpty, "Expected at least one map item for \(testCase.description)")
        
        let firstItem = mapItems[0]
        #expect(firstItem.name == testCase.expectedName,
                "Expected name '\(testCase.expectedName)' for \(testCase.description)")
        #expect(firstItem.placemark.coordinate.latitude == testCase.expectedLatitude,
                "Expected latitude \(testCase.expectedLatitude) for \(testCase.description)")
        #expect(firstItem.placemark.coordinate.longitude == testCase.expectedLongitude,
                "Expected longitude \(testCase.expectedLongitude) for \(testCase.description)")
    }
}
