import Testing
@testable import MapPlus

struct AddressLookupTests {
    
    // MARK: - MockAddressLookupService Tests
    
    @Test func testMockAddressLookupSuccessWithExactMatch() async throws {
        let service = MockAddressLookupService()
        
        let result = try await service.lookup(address: "San Francisco")
        
        #expect(result.formattedDescription == "San Francisco, CA, United States")
        #expect(result.coordinates.latitude == 37.7749)
        #expect(result.coordinates.longitude == -122.4194)
    }
    
    @Test func testMockAddressLookupSuccessWithCaseInsensitiveMatch() async throws {
        let service = MockAddressLookupService()
        
        let result = try await service.lookup(address: "san francisco")
        
        #expect(result.formattedDescription == "San Francisco, CA, United States")
        #expect(result.coordinates.latitude == 37.7749)
        #expect(result.coordinates.longitude == -122.4194)
    }
    
    @Test func testMockAddressLookupSuccessWithPartialMatch() async throws {
        let service = MockAddressLookupService()
        
        let result = try await service.lookup(address: "Francisco")
        
        #expect(result.formattedDescription == "San Francisco, CA, United States")
        #expect(result.coordinates.latitude == 37.7749)
        #expect(result.coordinates.longitude == -122.4194)
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
    
    @Test func testMockAddressLookupAllPredefinedAddresses() async throws {
        let service = MockAddressLookupService()
        
        // Test all predefined addresses
        let addresses = [
            ("San Francisco", "San Francisco, CA, United States", 37.7749, -122.4194),
            ("New York", "New York, NY, United States", 40.7128, -74.0060),
            ("London", "London, United Kingdom", 51.5074, -0.1278),
            ("Tokyo", "Tokyo, Japan", 35.6762, 139.6503),
            ("1 Infinite Loop", "1 Infinite Loop, Cupertino, CA 95014, United States", 37.3349, -122.0090)
        ]
        
        for (query, expectedDescription, expectedLat, expectedLon) in addresses {
            let result = try await service.lookup(address: query)
            #expect(result.formattedDescription == expectedDescription)
            #expect(result.coordinates.latitude == expectedLat)
            #expect(result.coordinates.longitude == expectedLon)
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
