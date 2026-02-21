//
//  LandmarkCategory.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/20/26.
//
import SwiftData

// TODO patmcg doc

@Model
class LandmarkCategory: Identifiable, Hashable {
    
    #Unique<LandmarkCategory>([\.name])
    
    var name: String
    
    @Relationship(inverse: \Landmark.categories)
    var landmarks: [Landmark] = []
    
    init(name: String) {
        self.name = name
    }
    
    var id: String {
        return name
    }
}
