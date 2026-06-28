//
//  MKMapItemExtensions.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//
import MapKit

extension MKMapItem {

    /// Generates a user-facing description of this map item, such as full address and/or place name.
    /// The result is typically a multi-line address but could be a basicname if no address is available.
    var fullDescription: String {
        buildFullDescription()
    }
    
    /// Builds the full description using a result builder pattern
    @MKMapItemStringResultBuilder
    private func buildFullDescription() -> String {
        // Include the name if it exists and is not already part of the address
        if let itemName = self.name,
           let fullAddress = self.addressRepresentations?.fullAddress(includingRegion: false, singleLine: false),
           !fullAddress.contains(itemName) {
            itemName
            fullAddress
        } else if let fullAddress = self.addressRepresentations?.fullAddress(includingRegion: false, singleLine: false) {
            fullAddress
        } else {
            self.name ?? self.location.description
        }
    }
    
}

// MARK: - String Result Builder

/// A result builder for constructing multi-line strings from optional components
@resultBuilder
enum MKMapItemStringResultBuilder {
    
    /// Builds a string from an array of optional components, filtering out nils and joining with newlines
    static func buildBlock(_ components: String?...) -> String {
        components.compactMap { $0 }.joined(separator: "\n")
    }
    
    /// Supports optional string components in the builder
    static func buildOptional(_ component: String?) -> String? {
        component
    }
    
    /// Supports if-else conditions in the builder
    static func buildEither(first component: String?) -> String? {
        component
    }
    
    /// Supports if-else conditions in the builder
    static func buildEither(second component: String?) -> String? {
        component
    }
}
