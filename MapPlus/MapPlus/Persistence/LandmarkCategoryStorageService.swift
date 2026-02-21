//
//  LandmarkCategoryStorageService.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/20/26.
//
import SwiftData

// TODO patmcg doc
struct LandmarkCategoryStorageService {

    /// The context under which to perform persistence operations
    let modelContext: ModelContext

    // TODO patmcg doc - actually deletes a whole category from all landmarks
    func delete(category: LandmarkCategory) {
        self.modelContext.delete(category)
    }
}
