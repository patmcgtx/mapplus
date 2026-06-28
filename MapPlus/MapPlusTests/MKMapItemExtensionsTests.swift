//
//  MKMapItemExtensionsTests.swift
//  MapPlusTests
//
//  Created by Patrick McGonigle on 6/28/26.
//

import Testing
import MapKit
import Contacts
@testable import MapPlus

@Suite("MKMapItem.fullDescription Tests")
struct MKMapItemExtensionsTests {

    // MARK: - Helpers

    private func makeMapItem(
        name: String? = nil,
        postalAddress: CNPostalAddress? = nil,
        latitude: Double = 37.3346,
        longitude: Double = -122.0090
    ) -> MKMapItem {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = postalAddress != nil
            ? MKPlacemark(coordinate: coordinate, postalAddress: postalAddress!)
            : MKPlacemark(coordinate: coordinate)
        let item = MKMapItem(placemark: placemark)
        item.name = name
        return item
    }

    private func makePostalAddress(
        street: String = "",
        city: String = "",
        state: String = "",
        postalCode: String = ""
    ) -> CNPostalAddress {
        let address = CNMutablePostalAddress()
        address.street = street
        address.city = city
        address.state = state
        address.postalCode = postalCode
        return address
    }

    // MARK: - No name, no address → coordinates

    @Test("Falls back to coordinates when name and address are both absent")
    func testCoordinateFallback() {
        let item = makeMapItem(latitude: 37.3346, longitude: -122.0090)
        let description = item.fullDescription
        #expect(description.contains("Unknown Location"))
    }

    // MARK: - Name only, no address

    @Test("Returns name when address is absent")
    func testNameOnly() {
        let item = makeMapItem(name: "Caffè Nero")
        #expect(item.fullDescription == "Caffè Nero")
    }

    // MARK: - Address only, no name

    @Test("Returns address when name is absent")
    func testAddressOnly() {
        let address = makePostalAddress(street: "1 Infinite Loop", city: "Cupertino", state: "CA", postalCode: "95014")
        let item = makeMapItem(postalAddress: address)
        let description = item.fullDescription
        #expect(description.contains("Infinite Loop"))
    }

    // MARK: - Name + address, name not in address

    @Test("Prepends name when it does not appear in the address")
    func testNamePrependedWhenNotInAddress() {
        let address = makePostalAddress(street: "1 Infinite Loop", city: "Cupertino", state: "CA", postalCode: "95014")
        let item = makeMapItem(name: "Apple HQ", postalAddress: address)
        let description = item.fullDescription
        #expect(description.hasPrefix("Apple HQ"))
    }

}
