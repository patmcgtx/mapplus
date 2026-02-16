import Testing
@testable import MapPlus

struct AddressLookupTests {
    
    // MARK: - MockAddressLookupService Tests
    
    // Test data for parameterized address lookup tests
    struct AddressLookupTestCase {
        let query: String
        let expectedDescription: String
        let expectedLatitude: Double
        let expectedLongitude: Double
        let description: String
    }
    
    @Test("Mock address lookup success cases", arguments: [
        AddressLookupTestCase(
            query: "San Francisco",
            expectedDescription: "San Francisco, CA, United States",
            expectedLatitude: 37.7749,
            expectedLongitude: -122.4194,
            description: "Exact match"
        ),
        AddressLookupTestCase(
            query: "san francisco",
            expectedDescription: "San Francisco, CA, United States",
            expectedLatitude: 37.7749,
            expectedLongitude: -122.4194,
            description: "Case insensitive match"
        ),
        AddressLookupTestCase(
            query: "Francisco",
            expectedDescription: "San Francisco, CA, United States",
            expectedLatitude: 37.7749,
            expectedLongitude: -122.4194,
            description: "Partial match"
        ),
        AddressLookupTestCase(
            query: "New York",
            expectedDescription: "New York, NY, United States",
            expectedLatitude: 40.7128,
            expectedLongitude: -74.0060,
            description: "New York exact match"
        ),
        AddressLookupTestCase(
            query: "London",
            expectedDescription: "London, United Kingdom",
            expectedLatitude: 51.5074,
            expectedLongitude: -0.1278,
            description: "London exact match"
        ),
        AddressLookupTestCase(
            query: "Tokyo",
            expectedDescription: "Tokyo, Japan",
            expectedLatitude: 35.6762,
            expectedLongitude: 139.6503,
            description: "Tokyo exact match"
        ),
        AddressLookupTestCase(
            query: "1 Infinite Loop",
            expectedDescription: "1 Infinite Loop, Cupertino, CA 95014, United States",
            expectedLatitude: 37.3349,
            expectedLongitude: -122.0090,
            description: "Apple headquarters exact match"
        )
    ])
    func testMockAddressLookupSuccess(testCase: AddressLookupTestCase) async throws {
        let service = MockAddressLookupService()
        
        let result = try await service.lookup(address: testCase.query)
        
        #expect(result.formattedDescription == testCase.expectedDescription,
                "Expected '\(testCase.expectedDescription)' for \(testCase.description)")
        #expect(result.coordinates.latitude == testCase.expectedLatitude,
                "Expected latitude \(testCase.expectedLatitude) for \(testCase.description)")
        #expect(result.coordinates.longitude == testCase.expectedLongitude,
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
                formattedDescription: "Custom Location",
                latitude: 12.34,
                longitude: 56.78
            ),
            queryAddress: "Any Address",
            description: "Basic custom address"
        ),
        CustomAddressTestCase(
            customAddress: LocationInfo(
                formattedDescription: "Test Headquarters",
                latitude: 40.7589,
                longitude: -73.9851
            ),
            queryAddress: "Times Square",
            description: "Custom address overrides known location"
        ),
        CustomAddressTestCase(
            customAddress: LocationInfo(
                formattedDescription: "Special Test Location",
                latitude: -33.8688,
                longitude: 151.2093
            ),
            queryAddress: "Sydney Opera House",
            description: "Custom address for different query"
        )
    ])
    func testMockAddressLookupSuccessWithCustomAddress(testCase: CustomAddressTestCase) async throws {
        let service = MockAddressLookupService(customAddress: testCase.customAddress)
        
        let result = try await service.lookup(address: testCase.queryAddress)
        
        #expect(result.formattedDescription == testCase.customAddress.formattedDescription,
                "Expected '\(testCase.customAddress.formattedDescription)' for \(testCase.description)")
        #expect(result.coordinates.latitude == testCase.customAddress.coordinates.latitude,
                "Expected latitude \(testCase.customAddress.coordinates.latitude) for \(testCase.description)")
        #expect(result.coordinates.longitude == testCase.customAddress.coordinates.longitude,
                "Expected longitude \(testCase.customAddress.coordinates.longitude) for \(testCase.description)")
    }
    
    // Test data for generic result tests (unknown addresses)
    struct GenericResultTestCase {
        let query: String
        let expectedDescription: String
        let description: String
    }
    
    @Test("Mock address lookup with generic results", arguments: [
        GenericResultTestCase(
            query: "Unknown Place",
            expectedDescription: "Unknown Place (Mock Result)",
            description: "Unknown place returns mock result"
        ),
        GenericResultTestCase(
            query: "Atlantis",
            expectedDescription: "Atlantis (Mock Result)",
            description: "Fictional location returns mock result"
        ),
        GenericResultTestCase(
            query: "Nowhere City",
            expectedDescription: "Nowhere City (Mock Result)",
            description: "Non-existent city returns mock result"
        ),
        GenericResultTestCase(
            query: "Random Address 123",
            expectedDescription: "Random Address 123 (Mock Result)",
            description: "Random address returns mock result"
        )
    ])
    func testMockAddressLookupSuccessWithGenericResult(testCase: GenericResultTestCase) async throws {
        let service = MockAddressLookupService()
        
        let result = try await service.lookup(address: testCase.query)
        
        #expect(result.formattedDescription == testCase.expectedDescription,
                "Expected '\(testCase.expectedDescription)' for \(testCase.description)")
        #expect(result.coordinates.latitude == 37.7749,
                "Expected default latitude for \(testCase.description)")
        #expect(result.coordinates.longitude == -122.4194,
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
            _ = try await service.lookup(address: testCase.queryAddress)
            Issue.record("Expected lookup to throw for \(testCase.description), but it did not")
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
        let expectedDescription: String
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
            _ = try await service.lookup(address: "Test Address")
        } catch {
            // Expected to fail in test environment
        }
    }
    
    @Test("Protocol interface with MockService", arguments: [
        ProtocolInterfaceTestCase(
            queryAddress: "San Francisco",
            expectedDescription: "San Francisco, CA, United States",
            expectedLatitude: 37.7749,
            expectedLongitude: -122.4194,
            description: "San Francisco through protocol"
        ),
        ProtocolInterfaceTestCase(
            queryAddress: "New York",
            expectedDescription: "New York, NY, United States",
            expectedLatitude: 40.7128,
            expectedLongitude: -74.0060,
            description: "New York through protocol"
        ),
        ProtocolInterfaceTestCase(
            queryAddress: "Tokyo",
            expectedDescription: "Tokyo, Japan",
            expectedLatitude: 35.6762,
            expectedLongitude: 139.6503,
            description: "Tokyo through protocol"
        )
    ])
    func testProtocolInterfaceWithMockService(testCase: ProtocolInterfaceTestCase) async throws {
        let service: AddressLookupService = MockAddressLookupService()
        
        // This test verifies we can use MockAddressLookupService through the protocol interface
        let result = try await service.lookup(address: testCase.queryAddress)
        
        #expect(result.formattedDescription == testCase.expectedDescription,
                "Expected '\(testCase.expectedDescription)' for \(testCase.description)")
        #expect(result.coordinates.latitude == testCase.expectedLatitude,
                "Expected latitude \(testCase.expectedLatitude) for \(testCase.description)")
        #expect(result.coordinates.longitude == testCase.expectedLongitude,
                "Expected longitude \(testCase.expectedLongitude) for \(testCase.description)")
    }
}
