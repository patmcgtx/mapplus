//
//  PointsOfInterestLevel.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/14/26.
//
import SwiftUI
import MapKit

/// Levels for which points of interest the user sees on the map.
/// Points of interest are background items of interest on the map.
enum PointsOfInterestLevel: String, CaseIterable, Identifiable {

    var id: String { self.rawValue }
    
    /// No background points of interest.
    case none
    
    /// A limited subset of points of interest, mostly related to safety.
    case limited
    
    /// All points of interest are shown.
    case all
    
    /// Gets the points of interest categories for this instance's level
    var categories: PointOfInterestCategories {
        switch self {
        case .none: return .excludingAll
        case .limited: return [
            .library,
            .school,
            .fireStation,
            .hospital,
            .pharmacy,
            .police
        ]
        case .all: return .all
        }
    }
    
    /// A localized user-facing name for the theme
    var localizedName: String {
        switch self {
        case .none:
            return "poi-none".localized
        case .limited:
            return "poi-limited".localized
        case .all:
            return "poi-all".localized
        }
    }
    
    /// Which icon should show for the overall PoI menu
    var menuIconName: String {
        switch self {
        case .none:
            return "square.2.layers.3d"
        case .limited:
            return "square.2.layers.3d.bottom.filled"
        case .all:
            return "square.2.layers.3d.fill"
        }
    }

}
