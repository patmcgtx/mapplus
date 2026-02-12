import Testing
@testable import MapPlus

struct CurrentLocationTests {
    
    // MARK: - MockCurrentLocationService Tests
    
    @Test func testMockCurrentLocationSuccess() async throws {
        let service: CurrentLocationProtocol = MockCurrentLocationService()
        
        let result = try await service.getCurrentLocation()
        
        #expect(result.formattedDescription.contains("Current Location"))
        #expect(result.latitude == 37.7749)
        #expect(result.longitude == -122.4194)
    }
    
    @Test func testMockCurrentLocationFailure() async throws {
        let service: CurrentLocationProtocol = MockCurrentLocationService(shouldSucceed: false)
        
        do {
            _ = try await service.getCurrentLocation()
            Issue.record("Expected getCurrentLocation to throw, but it did not")
        } catch let error as MapPlusError {
            #expect(error == .noAddressFound)
        } catch {
            Issue.record("Expected MapPlusError.noAddressFound, but got: \(error)")
        }
    }
    
    @Test func testMockCurrentLocationWithCustomAddress() async throws {
        let customAddress = AddressInfo(
            formattedDescription: "Custom Current Location",
            latitude: 40.7128,
            longitude: -74.0060
        )
        let service: CurrentLocationProtocol = MockCurrentLocationService(customAddress: customAddress)
        
        let result = try await service.getCurrentLocation()
        
        #expect(result.formattedDescription == "Custom Current Location")
        #expect(result.latitude == 40.7128)
        #expect(result.longitude == -74.0060)
    }
}
