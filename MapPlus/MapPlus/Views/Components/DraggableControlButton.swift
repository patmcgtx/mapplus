//
//  DraggableControlButton.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/10/26.
//
import SwiftUI

/// A movable/draggable button that performs the provided action when tapped.
struct DraggableControlButton: View {
    
    /// The offset to keep the parent view updated of the button's location
    @Binding var draggedOffset: CGSize
    
    /// The SF Symbols name for the buttons' icon
    let systemImageName: String
    
    /// The action to perform when the button is tapped
    let action: () -> Void
    
    // MARK: Private state
    
    @State private var isDragging: Bool = false
    @State private var dragOrigin: CGSize = .zero
    
    var body: some View {
        Button(action: {
            if !isDragging {
                action()
            }
        }) {
            Image(systemName: systemImageName)
                .resizable()
                .frame(width: 24, height: 24)
                .padding(16)
        }
        .glassEffect()
        .isBeingDragged(isDragging)
        .offset(draggedOffset)
        .simultaneousGesture(
            DragGesture()
                .onChanged { value in
                    if !isDragging {
                        withAnimation(.easeOut(duration: 0.15)) {
                            isDragging = true
                        }
                        dragOrigin = draggedOffset
                    }
                    draggedOffset = CGSize(
                        width: dragOrigin.width + value.translation.width,
                        height: dragOrigin.height + value.translation.height
                    )
                }
                .onEnded { value in
                    // Defer the reset so the Button action (which fires on the same
                    // touch-up event) still sees isAddButtonDragging == true and
                    // skips opening the sheet.
                    DispatchQueue.main.async {
                        withAnimation(.easeOut(duration: 0.15)) {
                            isDragging = false
                        }
                    }
                }
        )
    }
}

#Preview {
    
    @Previewable @State var addButtonOffset: CGSize = .zero
    @Previewable @State var addButtonPressed: Bool = false
    
    @Previewable @State var locateButtonPressed: Bool = false
    @Previewable @State var locateButtonOffset: CGSize = .zero
    
    VStack {
        
        DraggableControlButton(
            draggedOffset: $addButtonOffset,
            systemImageName: "plus",
            action: {
                addButtonPressed = true
            }
        )
        .alert("Hey!", isPresented: $addButtonPressed, actions: {}, message: {
            Text("You tapped the add button. ➕")
        })
        
        DraggableControlButton(
            draggedOffset: $locateButtonOffset,
            systemImageName: "location",
            action: {
                locateButtonPressed = true
            }
        )
        .alert("Hey!", isPresented: $locateButtonPressed, actions: {}, message: {
            Text("You tapped the locate button. 📍")
        })
    }
}
