//
//  FlowLayout.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 2/19/26.
//

import SwiftUI

/// A custom `Layout` that arranges subviews in a left-to-right flow,
/// wrapping to the next line when a row is full — like HTML inline elements or tags.
struct FlowLayout: Layout {

    var horizontalSpacing: CGFloat = 8
    var verticalSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(availableWidth: proposal.width ?? .infinity, subviews: subviews)
        let totalHeight = rows.reduce(0) { $0 + $1.maxHeight }
            + CGFloat(max(0, rows.count - 1)) * verticalSpacing
        return CGSize(width: proposal.width ?? 0, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(availableWidth: bounds.width, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for item in row.items {
                item.subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(item.size))
                x += item.size.width + horizontalSpacing
            }
            y += row.maxHeight + verticalSpacing
        }
    }

    // MARK: - Private helpers

    private struct RowItem {
        let subview: LayoutSubview
        let size: CGSize
    }

    private struct Row {
        var items: [RowItem] = []
        var maxHeight: CGFloat { items.map { $0.size.height }.max() ?? 0 }
    }

    private func computeRows(availableWidth: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row()
        var rowWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let needed = currentRow.items.isEmpty
                ? size.width
                : rowWidth + horizontalSpacing + size.width

            if needed > availableWidth && !currentRow.items.isEmpty {
                rows.append(currentRow)
                currentRow = Row()
                rowWidth = size.width
            } else {
                rowWidth = needed
            }
            currentRow.items.append(RowItem(subview: subview, size: size))
        }

        if !currentRow.items.isEmpty {
            rows.append(currentRow)
        }

        return rows
    }
}
