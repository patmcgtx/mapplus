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
    let onTap: () -> Void

    /// The action to perform when the button has been dropped in a new spot
    let onMoved: () -> Void

    // MARK: Private state
    
    @State private var isDragging: Bool = false
    @State private var dragOrigin: CGSize = .zero
    
    var body: some View {
        Button(action: {
            if !isDragging {
                onTap()
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
                    onMoved()
                }
        )
    }
}

#Preview {
    
    @Previewable @State var addButtonOffset: CGSize = .zero
    @Previewable @State var addButtonPressed: Bool = false
    @Previewable @State var addButtonMoved: Bool = false

    @Previewable @State var locateButtonOffset: CGSize = .zero
    @Previewable @State var locateButtonPressed: Bool = false
    @Previewable @State var locateButtonMoved: Bool = false

    VStack {
        
        DraggableControlButton(
            draggedOffset: $addButtonOffset,
            systemImageName: "plus",
            onTap: {
                addButtonPressed = true
            },
            onMoved: {
                addButtonMoved = true
            }
        )
        .alert("Hey! 👇", isPresented: $addButtonPressed, actions: {}, message: {
            Text("Add button tapped ➕")
        })
        .alert("Huh?", isPresented: $addButtonMoved, actions: {}, message: {
            Text("Add button moved 👀")
        })

        DraggableControlButton(
            draggedOffset: $locateButtonOffset,
            systemImageName: "location",
            onTap: {
                locateButtonPressed = true
            },
            onMoved: {
                locateButtonMoved = true
            }
        )
        .alert("Hey! 👇", isPresented: $locateButtonPressed, actions: {}, message: {
            Text("Locate button tapped 📍")
        })
        .alert("Huh?", isPresented: $locateButtonMoved, actions: {}, message: {
            Text("TLocate button moved 👀")
        })
    }
}
