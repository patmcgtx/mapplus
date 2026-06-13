//
//  Dragged.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/10/26.
//
import SwiftUI

/// View modifier to visually express that a view is actively being dragged
struct Dragged: ViewModifier {
    
    let isBeingDragged: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isBeingDragged ? 1.25 : 1.0)
            .opacity(isBeingDragged ? 0.6 : 1.0)
            .zIndex(isBeingDragged ? 1 : 0)
    }
}

extension View {
    
    /// Applies the `Dragged` view modifier to a view
    func isBeingDragged(_ isBeingDragged: Bool) -> some View {
        modifier(Dragged(isBeingDragged: isBeingDragged))
    }
}
