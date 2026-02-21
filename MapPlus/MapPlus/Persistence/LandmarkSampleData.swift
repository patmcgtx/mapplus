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
struct LandmarkSampleData {
    
    // MARK: - Landmark categories

    var categoryCafes: LandmarkCategory {
        LandmarkCategory(name: "Cafes")
    }
    
    var categoryPersonal: LandmarkCategory {
        LandmarkCategory(name: "Personal")
    }
    
    var categoryFun: LandmarkCategory {
        LandmarkCategory(name: "Fun")
    }

    var categoryHotel: LandmarkCategory {
        LandmarkCategory(name: "Hotel")
    }
    
    var allCategories: [LandmarkCategory] {
        [categoryCafes, categoryPersonal, categoryFun, categoryHotel]
    }
    
    // MARK: - Around Austin

    var capital: Landmark {
        Landmark(
            name: "Texas Capital Lawn",
            notes: "Lawn of the Texas state capital building.",
            formattedAddress: "1100 Congress Ave\nAustin, TX 78701",
            systemImageName: "building",
            location: CLLocationCoordinate2D(
                latitude: 30.27381,
                longitude: -97.74063
            ),
            categories: [categoryFun]
        )
    }

    var coffee: Landmark {
        Landmark(
            name: "Cosmic Coffee & Beer Garden",
            notes: "A good place for coffee & beer. 🍻",
            formattedAddress: "121 Pickle Rd\nSte 111\nAustin, TX 78704",
            systemImageName: "mug",
            location: CLLocationCoordinate2D(
                latitude: 30.22744,
                longitude: -97.76237
            ),
            categories: [categoryCafes, categoryFun]
        )
    }
    
    var school: Landmark {
        Landmark(
            name: "School",
            notes: "Learning and such.",
            formattedAddress: "123 School",
            systemImageName: "graduationcap",
            location: CLLocationCoordinate2D(
                latitude: 30.20632,
                longitude: -97.77506
            ),
            categories: [categoryPersonal]
        )
    }
    
    var work: Landmark {
        Landmark(
            name: "Work",
            notes: "Another day, another dollar.",
            formattedAddress: "123 Work",
            systemImageName: "arcade.stick",
            location: CLLocationCoordinate2D(
                latitude: 30.27267,
                longitude: -97.74109
            ),
            categories: [categoryPersonal]
        )
    }


    /// A few landmarks around Austin, Texas
    var austinPlaces: [Landmark] {
        [capital, coffee, school, work]
    }

    // MARK: - Global sites
    
    var nyc: Landmark {
        Landmark(
            name: "By the Brooklyn Bridge",
            notes: "Under the bridge, views of Manhattan",
            formattedAddress: "1 Water St\nBrooklyn, NY 11201",
            systemImageName: "theatermasks",
            location: CLLocationCoordinate2D(
                latitude: 40.70352,
                longitude: -73.99449
            ),
            categories: [categoryFun]
        )
    }
    
    var london: Landmark {
        Landmark(
            name: "Charing Cross, London",
            notes: "Where six routes meet.",
            formattedAddress: "Charing Cross\nLondon WC2N\nEngland UK",
            systemImageName: "train.side.rear.car",
            location: CLLocationCoordinate2D(
                latitude: 51.5074,
                longitude: -0.1278
            ),
            categories: [categoryFun]
        )
    }
    
    var tokyo: Landmark {
        Landmark(
            name: "Park Hyatt Tokyo",
            notes: "Lost in translation.",
            formattedAddress: "〒163-1055\n東京都新宿区\n西新宿3丁目7-1-2",
            systemImageName: "film",
            location: CLLocationCoordinate2D(
                latitude: 35.68529,
                longitude: 139.69072
            ),
            categories: [categoryFun, categoryHotel]
        )
    }

    /// A few landmarks around the world
    var globalPlaces: [Landmark] {
        [nyc, london, tokyo]
    }

}
