//
//  FlowLayout.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/23/26.
//

import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let width = proposal.width ?? 300
        let layout = calculateLayout(subviews, width: width)

        return CGSize(width: width, height: layout.height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let layout = calculateLayout(subviews, width: bounds.width)

        for (index, position) in layout.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(
                    x: bounds.minX + position.x,
                    y: bounds.minY + position.y
                ),
                proposal: .unspecified
            )
        }
    }

    private func calculateLayout(
        _ subviews: Subviews,
        width: CGFloat
    ) -> (positions: [CGPoint], height: CGFloat) {
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if x > 0 && x + size.width > width {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }

            positions.append(CGPoint(x: x, y: y))

            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        return (
            positions,
            subviews.isEmpty ? 0 : y + rowHeight
        )
    }
}
