//
//  SampleCategories.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/21/26.
//


/// Some sample categories for development and testing.
struct SampleCategories {
    
    var cafes: LandmarkCategory {
        LandmarkCategory(name: "Cafes")
    }
    
    var fun: LandmarkCategory {
        LandmarkCategory(name: "Fun")
    }

    var education: LandmarkCategory {
        LandmarkCategory(name: "Education")
    }

    var historic: LandmarkCategory {
        LandmarkCategory(name: "Historic")
    }

    var hotels: LandmarkCategory {
        LandmarkCategory(name: "Hotel")
    }
    
    var all: [LandmarkCategory] {
        [cafes, fun, education, historic, hotels]
    }
}
