//
//  Dragged.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/10/26.
//
import SwiftUI

// TODO patmcg doc
struct Dragged: ViewModifier {
    
    let isBeingDragged: Bool
    
    func body(content: Content) -> some View {
        content
        // TODO patmcg fix magic numbers
            .scaleEffect(isBeingDragged ? 1.25 : 1.0)
            .opacity(isBeingDragged ? 0.6 : 1.0)
            .zIndex(isBeingDragged ? 1 : 0)
    }
}

// TODO patmcg doc
extension View {
    func isBeingDragged(_ isBeingDragged: Bool) -> some View {
        modifier(Dragged(isBeingDragged: isBeingDragged))
    }
}
