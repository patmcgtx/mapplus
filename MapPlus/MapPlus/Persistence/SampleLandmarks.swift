//
//  LandmarkSampleData.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 10/15/25.
//

import SwiftData
import SwiftUI
import MapKit



/// Some sample landmarks for development and testing.
struct SampleLandmarks {
    
    private var categories = SampleCategories()
    
    // MARK: - Around Austin

    var capital: Landmark {
        Landmark(
            name: "Texas Capital Lawn",
            notes: "Lawn of the Texas state capital building.",
            formattedAddress: "1100 Congress Ave\nAustin, TX 78701",
            emoji: "🏛️",
            location: CLLocationCoordinate2D(
                latitude: 30.27381,
                longitude: -97.74063
            ),
            categories: [categories.fun]
        )
    }

    var coffee: Landmark {
        Landmark(
            name: "Cosmic Coffee & Beer Garden",
            notes: "A good place for coffee & beer. 🍻",
            formattedAddress: "121 Pickle Rd\nSte 111\nAustin, TX 78704",
            emoji: "☕️",
            location: CLLocationCoordinate2D(
                latitude: 30.22744,
                longitude: -97.76237
            ),
            categories: [categories.cafes, categories.fun]
        )
    }
    
    var school: Landmark {
        Landmark(
            name: "School",
            notes: "Learning and such.",
            formattedAddress: "123 School",
            emoji: "📚",
            location: CLLocationCoordinate2D(
                latitude: 30.20632,
                longitude: -97.77506
            ),
            categories: [categories.education]
        )
    }
    
    var work: Landmark {
        Landmark(
            name: "Work",
            notes: "Another day, another dollar.",
            formattedAddress: "123 Work",
            emoji: "🏢",
            location: CLLocationCoordinate2D(
                latitude: 30.27267,
                longitude: -97.74109
            ),
            categories: []
        )
    }


    /// A few landmarks around Austin, Texas
    var austinPlaces: [Landmark] {
        [capital, coffee, school, work]
    }

    // MARK: - Global sites
    
    var brooklynBridge: Landmark {
        Landmark(
            name: "Brooklyn Bridge",
            notes: "Under the bridge, views of Manhattan",
            formattedAddress: "1 Water St\nBrooklyn, NY 11201",
            emoji: "🌉",
            location: CLLocationCoordinate2D(
                latitude: 40.70584,
                longitude: -73.99642
            ),
            categories: [categories.fun]
        )
    }
    
    var charingCross: Landmark {
        Landmark(
            name: "Charing Cross, London",
            notes: "Where six routes meet.",
            formattedAddress: "Charing Cross\nLondon WC2N\nEngland UK",
            emoji: "🚉",
            location: CLLocationCoordinate2D(
                latitude: 51.5074,
                longitude: -0.1278
            ),
            categories: [categories.fun]
        )
    }
    
    var lostInTranslation: Landmark {
        Landmark(
            name: "Park Hyatt Tokyo",
            notes: "From _Lost in Translation_.",
            formattedAddress: "〒163-1055\n東京都新宿区\n西新宿3丁目7-1-2",
            emoji: "🇯🇵",
            location: CLLocationCoordinate2D(
                latitude: 35.68529,
                longitude: 139.69072
            ),
            categories: [categories.fun]
        )
    }

    /// A few landmarks around the world
    var globalPlaces: [Landmark] {
        [brooklynBridge, charingCross, lostInTranslation]
    }

}
