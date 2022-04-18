//
//  TrackLaneDragGestureBackground.swift
//  
//
//  Created by nori on 2022/04/18.
//

import SwiftUI

struct TrackLaneDragGestureBackground: View {
    
    @Environment(\.laneRange) var laneRange: Range<Int>

    @Environment(\.trackEditorOptions) var options: TrackEditorOptions

    @Environment(\.selection) var selection: Binding<EditingSelection?>

    @Environment(\.trackEditorNamespace) var namespace: Namespace

    func period(for frame: CGRect) -> Range<CGFloat> {
        let start = round((frame.minX - options.headerWidth) / options.barWidth)
        let end = round((frame.maxX - options.headerWidth) / options.barWidth)
        return start..<end
    }

    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    if self.selection.wrappedValue != nil {
                        self.selection.wrappedValue = nil
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                            let frame = CGRect(x: value.startLocation.x - options.barWidth / 2, y: value.startLocation.y, width: options.barWidth, height: options.trackHeight).offsetBy(dx: value.translation.width, dy: value.translation.height)
                            let position = CGPoint(x: frame.midX, y: frame.midY)
                            let period = period(for: frame)
                            self.selection.wrappedValue = EditingSelection(id: nil, position: position, size: frame.size, period: period, state: .dragging)
                        }
                        .onEnded { value in
                            var frame = CGRect(x: value.startLocation.x - options.barWidth / 2, y: value.startLocation.y, width: options.barWidth, height: options.trackHeight).offsetBy(dx: value.translation.width, dy: value.translation.height)
                            frame.origin.x = round((frame.minX - options.headerWidth) / options.barWidth) * options.barWidth + options.headerWidth
                            frame.origin.y = round((frame.minY - options.rulerHeight) / options.trackHeight) * options.trackHeight + options.rulerHeight
                            let position = CGPoint(x: frame.midX, y: frame.midY)
                            let period = period(for: frame)
                            withAnimation(.interactiveSpring(response: 0.1, dampingFraction: 0.6, blendDuration: 0)) {
                                selection.wrappedValue = EditingSelection(id: nil, position: position, size: frame.size, period: period, state: .focused)
                            }
                        }
                )
        }
    }
}
