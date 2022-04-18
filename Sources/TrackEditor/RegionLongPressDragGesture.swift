//
//  SwiftUIView.swift
//  
//
//  Created by nori on 2022/04/17.
//

import SwiftUI

struct RegionLongPressDragGesture: Gesture {

    @Environment(\.laneRange) var laneRange: Range<Int>

    @Environment(\.trackEditorOptions) var options: TrackEditorOptions

    @Environment(\.selection) var selection: Binding<EditingSelection?>

    @Environment(\.trackEditorNamespace) var namespace: Namespace

    var id: String?

    var frame: CGRect

    var size: CGSize { frame.size }

    var isDragging: Bool = false

    func period(for frame: CGRect) -> Range<CGFloat> {
        let start = round((frame.minX - options.headerWidth) / options.barWidth)
        let end = round((frame.maxX - options.headerWidth) / options.barWidth)
        return start..<end
    }

    var body: some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
            .onChanged { value in
                switch value {
                    case .first(true): break
                    case .second(true, let drag):
                        if let drag = drag {
                            let frame = frame.offsetBy(dx: drag.translation.width, dy: drag.translation.height)
                            let position = CGPoint(x: frame.midX, y: frame.midY)
                            let period = period(for: frame)
                            selection.wrappedValue = EditingSelection(id: id, position: position, size: size, period: period, state: .dragging)
                        } else {
                            let position = CGPoint(x: frame.midX, y: frame.midY)
                            let period = period(for: frame)
                            selection.wrappedValue = EditingSelection(id: id, position: position, size: size, period: period, state: .pressing)
                        }
                    default: break
                }
            }
            .onEnded { value in
                guard case .second(true, let drag?) = value else { return }
                var frame = frame.offsetBy(dx: drag.predictedEndTranslation.width, dy: drag.predictedEndTranslation.height)
                frame.origin.x = round((frame.minX - options.headerWidth) / options.barWidth) * options.barWidth + options.headerWidth
                frame.origin.y = round((frame.minY - options.rulerHeight) / options.trackHeight) * options.trackHeight + options.rulerHeight
                let position = CGPoint(x: frame.midX, y: frame.midY)
                let period = period(for: frame)
                withAnimation(.interactiveSpring()) {
                    selection.wrappedValue = EditingSelection(id: id, position: position, size: size, period: period, state: .focused)
                }
            }
    }
}
