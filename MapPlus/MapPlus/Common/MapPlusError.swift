//
//  MapPlusError.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/31/26.
//

enum MapPlusError: Error {
    
    case noAddressFound
    
    // TODO patmcg localize
    var errorMessage: String {
        switch self {
        case .noAddressFound:
            return "No address found"
        }
    }
}
