//
//  LandmarkCategorySampleData.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/20/26.
//

// TODO patmcg doc

struct LandmarkCategorySampleData {

    var cafes: LandmarkCategory {
        LandmarkCategory(name: "Cafes")
    }

    var schools: LandmarkCategory {
        LandmarkCategory(name: "Schools")
    }
    
    var museums: LandmarkCategory {
        LandmarkCategory(name: "Museums")
    }
    
    var categories: [LandmarkCategory] {
        [cafes, schools, museums]
    }
    
}
