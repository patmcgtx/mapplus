//
//  SampleCategories.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/21/26.
//


/// Some sample categories for development and testing.
struct SampleCategories {

    var family: LandmarkCategory {
        LandmarkCategory(name: "Family")
    }
    
    var fun: LandmarkCategory {
        LandmarkCategory(name: "Fun")
    }
    
    var work: LandmarkCategory {
        LandmarkCategory(name: "Work")
    }

    var cafes: LandmarkCategory {
        LandmarkCategory(name: "Cafes")
    }

    
    var all: [LandmarkCategory] {
        [family, fun, work, cafes]
    }
}
