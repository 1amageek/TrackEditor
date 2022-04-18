//
//  RegionDragGestureOverlay.swift
//  
//
//  Created by nori on 2022/04/17.
//

import SwiftUI

struct RegionDragGestureOverlay: View {

    @Environment(\.laneRange) var laneRange: Range<Int>

    @Environment(\.trackEditorOptions) var options: TrackEditorOptions

    @Environment(\.selection) var selection: Binding<EditingSelection?>

    @Environment(\.trackEditorNamespace) var namespace: Namespace

    var id: String?

    var tag: AnyHashable

    func period(for frame: CGRect) -> Range<CGFloat> {
        let start = round((frame.minX - options.headerWidth) / options.barWidth)
        let end = round((frame.maxX - options.headerWidth) / options.barWidth)
        return start..<end
    }

    var body: some View {
        GeometryReader { proxy in
            let frame = proxy.frame(in: .named(namespace.wrappedValue))
            let size = proxy.size
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                            let frame = frame.offsetBy(dx: value.translation.width, dy: value.translation.height)
                            let position = CGPoint(x: frame.midX, y: frame.midY)
                            let period = period(for: frame)
                            selection.wrappedValue = EditingSelection(id: id, tag: tag, position: position, size: size, period: period, state: .dragging)
                        }
                        .onEnded { value in
                            var frame = frame.offsetBy(dx: value.predictedEndTranslation.width, dy: value.predictedEndTranslation.height)
                            frame.origin.x = round((frame.minX - options.headerWidth) / options.barWidth) * options.barWidth + options.headerWidth
                            frame.origin.y = round((frame.minY - options.rulerHeight) / options.trackHeight) * options.trackHeight + options.rulerHeight
                            let position = CGPoint(x: frame.midX, y: frame.midY)
                            let period = period(for: frame)
                            withAnimation(.interactiveSpring(response: 0.1, dampingFraction: 0.6, blendDuration: 0)) {
                                selection.wrappedValue = EditingSelection(id: id, tag: tag, position: position, size: size, period: period, state: .focused)
                            }
                        }
                )
        }
    }
}
