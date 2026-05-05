//
//  MapsPlusSettingsStore.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 5/4/26.
//
import SwiftData

// TODO patmcg any reason to use a protocol here?  It is rly needed for testing?

// TODO patmcg doc all - this is sort of like a view model
struct MapsPlusSettingsStore {
        
    // TODO patmcg doc
    let modelContext: ModelContext
    
    // TODO patmcg doc - note it could return an in-memory only setting instance
    var settings: MapsPlusSettings {
        var descriptor = FetchDescriptor<MapsPlusSettings>()
        descriptor.fetchLimit = 1
        if let retval = try? modelContext.fetch(descriptor).first {
            return retval
        } else {
            let settings = MapsPlusSettings()
            try? modelContext.save()
            return settings
        }
    }
    
}
