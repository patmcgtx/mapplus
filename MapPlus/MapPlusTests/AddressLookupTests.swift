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
    
    @Test func testMockAddressLookupSuccessWithCustomAddress() async throws {
        let customAddress = LocationInfo(
            formattedDescription: "Custom Location",
            latitude: 12.34,
            longitude: 56.78
        )
        let service = MockAddressLookupService(customAddress: customAddress)
        
        let result = try await service.lookup(address: "Any Address")
        
        #expect(result.formattedDescription == "Custom Location")
        #expect(result.coordinates.latitude == 12.34)
        #expect(result.coordinates.longitude == 56.78)
    }
    
    @Test func testMockAddressLookupSuccessWithGenericResult() async throws {
        let service = MockAddressLookupService()
        
        let result = try await service.lookup(address: "Unknown Place")
        
        #expect(result.formattedDescription == "Unknown Place (Mock Result)")
        #expect(result.coordinates.latitude == 37.7749)
        #expect(result.coordinates.longitude == -122.4194)
    }
    
    @Test func testMockAddressLookupFailure() async throws {
        let service = MockAddressLookupService(shouldSucceed: false)
        
        do {
            _ = try await service.lookup(address: "Any Address")
            Issue.record("Expected lookup to throw, but it did not")
        } catch let error as MapPlusError {
            #expect(error == .noAddressFound)
        } catch {
            Issue.record("Expected MapPlusError.noAddressFound, but got: \(error)")
        }
    }
    
    // MARK: - Protocol Interface Tests
    
    @Test func testProtocolInterfaceWithMapKitService() async throws {
        let service: AddressLookupService = MapKitAddressLookupService()
        
        // This test verifies we can use MapKitAddressLookupService through the protocol interface
        // We expect it to fail in a sandboxed test environment without MapKit access
        do {
            _ = try await service.lookup(address: "Test Address")
        } catch {
            // Expected to fail in test environment
        }
    }
    
    @Test func testProtocolInterfaceWithMockService() async throws {
        let service: AddressLookupService = MockAddressLookupService()
        
        // This test verifies we can use MockAddressLookupService through the protocol interface
        let result = try await service.lookup(address: "San Francisco")
        
        #expect(result.formattedDescription == "San Francisco, CA, United States")
        #expect(result.coordinates.latitude == 37.7749)
        #expect(result.coordinates.longitude == -122.4194)
    }
}
