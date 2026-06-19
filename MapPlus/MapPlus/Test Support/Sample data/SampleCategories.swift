//
//  SampleCategories.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/21/26.
//
#if DEBUG

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

    var arcades: LandmarkCategory {
        LandmarkCategory(name: "Arcades")
    }

    var clothing: LandmarkCategory {
        LandmarkCategory(name: "Clothing")
    }

    var thrifting: LandmarkCategory {
        LandmarkCategory(name: "Thrifting")
    }
    
    var all: [LandmarkCategory] {
        [family, fun, work, cafes]
    }
    
    /// Generate a large number of categories for edge and stress testing
    func manyCategories(howMany count: Int) -> [LandmarkCategory] {
        var retval = [LandmarkCategory]()
        for catNum in 0..<count {
            let categoryName = "Category \(catNum)"
            retval.append(LandmarkCategory(name: categoryName))
        }
        return retval
    }
}

#endif // DEBUG
