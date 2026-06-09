//
//  DraggableControlButton.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 3/10/26.
//
import SwiftUI

/// A movable/draggable button that performs the provided action when tapped.
struct DraggableControlButton: View {
    
    // MARK: Properties
    
    /// The SF Symbols name for the buttons' icon
    let systemImageName: String
    
    /// The action to perform when the button is tapped
    let onTap: () -> Void

    /// The action to perform when the button has been dropped in a new spot,
    /// with a parameter giving its new offset from the original location.
    let onMoved: (CGSize) -> Void
    
    // MARK: Environment
    
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    // MARK: App storage
    
    @AppStorage(AppStorageKeys.theme.rawValue)
    private var theme: MapPlusTheme = .cupertino

    // MARK: View state

    @State
    private var draggedOffset: CGSize = .zero
    
    @State
    private var isDragging: Bool = false
    
    @State
    private var dragOrigin: CGSize = .zero
    
    @State
    private var originalCenter: CGPoint? = nil
    
    // MARK: Constants
    
    private let buttonSize: CGFloat = 24
    private let buttonPadding: CGFloat = 16
    private let snapInterval: CGFloat = 22

    // MARK: Views
    
    var body: some View {
        GeometryReader { geometry in
            Button(action: {
                if !isDragging {
                    onTap()
                }
            }) {
                Image(systemName: systemImageName)
                    .resizable()
                    .frame(width: buttonSize, height: buttonSize)
                    .padding(buttonPadding)
            }
            .foregroundStyle(theme.tintColor)
            .glassEffect()
            .isBeingDragged(isDragging)
            .sensoryFeedback(.impact(weight: .medium), trigger: isDragging) { _, isDragging in isDragging }
            .sensoryFeedback(.impact(weight: .light), trigger: isDragging) { _, isDragging in !isDragging }
            .offset(draggedOffset)
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        if !isDragging {
                            withAnimation(.easeOut(duration: 0.15)) {
                                isDragging = true
                            }
                            dragOrigin = draggedOffset
                            
                            // Capture the original center position in global coordinates
                            if originalCenter == nil {
                                let frame = geometry.frame(in: .global)
                                originalCenter = CGPoint(
                                    x: frame.midX + draggedOffset.width,
                                    y: frame.midY + draggedOffset.height
                                )
                            }
                        }
                        draggedOffset = CGSize(
                            width: dragOrigin.width + value.translation.width,
                            height: dragOrigin.height + value.translation.height
                        )
                    }
                    .onEnded { value in
                        // Snap to the global 100-point grid
                        if let original = originalCenter {
                            let snappedOffset = CGSize(
                                width: snapToGlobalGrid(draggedOffset.width, original: original.x),
                                height: snapToGlobalGrid(draggedOffset.height, original: original.y)
                            )
                            draggedOffset = snappedOffset
                            
                            // Defer the reset so the Button action (which fires on the same
                            // touch-up event) still sees isDragging == true and
                            // skips opening the sheet.
                            DispatchQueue.main.async {
                                withAnimation(.easeOut(duration: 0.15)) {
                                    isDragging = false
                                }
                            }
                            onMoved(snappedOffset)
                        }
                    }
            )
            .onAppear {
                // Capture initial position on appear
                let frame = geometry.frame(in: .global)
                originalCenter = CGPoint(x: frame.midX, y: frame.midY)
            }
        }
        .frame(width: buttonSize + buttonPadding * 2, height: buttonSize + buttonPadding * 2)
    }
    
    // MARK: Private helpers
    
    /// Snaps a coordinate value to the nearest grid point on a global grid
    private func snapToGlobalGrid(_ value: CGFloat, original: CGFloat) -> CGFloat {
        // Calculate the absolute position
        let absolutePosition = original + value
        
        // Snap to the nearest grid
        let snappedAbsolute = round(absolutePosition / snapInterval) * snapInterval
        
        // Convert back to offset from original
        return snappedAbsolute - original
    }

}

#if DEBUG

#Preview {
    
    @Previewable @State var addButtonPressed: Bool = false
    @Previewable @State var addButtonMoved: Bool = false
    @Previewable @State var locateButtonPressed: Bool = false
    @Previewable @State var locateButtonMoved: Bool = false

    VStack {        
        DraggableControlButton(
            systemImageName: "plus",
            onTap: {
                addButtonPressed = true
            },
            onMoved: {_ in 
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
            systemImageName: "location",
            onTap: {
                locateButtonPressed = true
            },
            onMoved: {_ in 
                locateButtonMoved = true
            }
        )
        .alert("Hey! 👇", isPresented: $locateButtonPressed, actions: {}, message: {
            Text("Locate button tapped 📍")
        })
        .alert("Huh?", isPresented: $locateButtonMoved, actions: {}, message: {
            Text("Locate button moved 👀")
        })
    }
}

#endif // DEBUG
