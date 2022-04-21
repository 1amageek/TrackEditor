//
//  RegionDragGestureOverlay.swift
//  
//
//  Created by nori on 2022/04/17.
//

import SwiftUI

struct RegionDragGestureOverlay: View {

    @Environment(\.laneRange) var laneRange: Range<Int>

    @Environment(\.trackOptions) var options: TrackOptions

    @Environment(\.selection) var selection: Binding<RegionSelection?>

    @Environment(\.onTrackDragGestureChanged) var onTrackDragGestureChanged: (() -> Void)?

    @Environment(\.onTrackDragGestureEnded) var onTrackDragGestureEnded: ((RegionAddress, RegionMoveAction) -> Void)?

    @Environment(\.trackNamespace) var trackNamespace: Namespace

    var regionID: String?

    var laneID: String

    var trackGeometory: GeometryProxy
    
    var preferenceValue: [LanePreference]

    func period(for frame: CGRect) -> Range<CGFloat> {
        let start = round((frame.minX - options.headerWidth) / options.barWidth)
        let end = round((frame.maxX - options.headerWidth) / options.barWidth)
        return start..<end
    }

    var body: some View {
        GeometryReader { proxy in
            let frame = proxy.frame(in: .named(trackNamespace.wrappedValue))
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .named(trackNamespace.wrappedValue))
                        .onChanged { value in
                            TrackGestureHandler(laneRange: laneRange, options: options, regionSelection: selection.wrappedValue, onTrackDragGestureChanged: onTrackDragGestureChanged, onTrackDragGestureEnded: onTrackDragGestureEnded)
                                .onDragGestureChanged(id: regionID, laneID: laneID, frame: frame, gesture: value, geometoryProxy: trackGeometory) { value in
                                    self.selection.wrappedValue = value
                                }
                        }
                        .onEnded { value in
                            TrackGestureHandler(laneRange: laneRange, options: options, regionSelection: selection.wrappedValue, onTrackDragGestureChanged: onTrackDragGestureChanged, onTrackDragGestureEnded: onTrackDragGestureEnded)
                                .onDragGestureEnded(id: regionID, laneID: laneID, frame: frame, gesture: value, geometoryProxy: trackGeometory, lanePreferences: preferenceValue) { value in
                                    withAnimation(.interactiveSpring(response: 0.1, dampingFraction: 0.6, blendDuration: 0)) {
                                        selection.wrappedValue = value
                                    }
                                }
                        }
                )
        }
    }
}
