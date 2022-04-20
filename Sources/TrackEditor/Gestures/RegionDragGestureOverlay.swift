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

    @Environment(\.onRegionDragGestureChanged) var onRegionDragGestureChanged: (() -> Void)?

    @Environment(\.onRegionDragGestureEnded) var onRegionDragGestureEnded: ((RegionAddress, RegionMoveAction) -> Void)?

    @Environment(\.trackNamespace) var namespace: Namespace

    var regionID: AnyHashable?

    var laneID: AnyHashable

    var geometory: GeometryProxy

    var preferenceValue: [LanePreference]

    func period(for frame: CGRect) -> Range<CGFloat> {
        let start = round((frame.minX - options.headerWidth) / options.barWidth)
        let end = round((frame.maxX - options.headerWidth) / options.barWidth)
        return start..<end
    }

    var body: some View {
        GeometryReader { proxy in
            let frame = proxy.frame(in: .named(namespace.wrappedValue))
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                            LaneDragGestureHandler(laneRange: laneRange, options: options, regionSelection: selection.wrappedValue, onRegionDragGestureChanged: onRegionDragGestureChanged, onRegionDragGestureEnded: onRegionDragGestureEnded)
                                .onDragGestureChanged(id: regionID, laneID: laneID, frame: frame, gesture: value, geometoryProxy: proxy) { value in
                                    self.selection.wrappedValue = value
                                }
                        }
                        .onEnded { value in
                            LaneDragGestureHandler(laneRange: laneRange, options: options, regionSelection: selection.wrappedValue, onRegionDragGestureChanged: onRegionDragGestureChanged, onRegionDragGestureEnded: onRegionDragGestureEnded)
                                .onDragGestureEnded(id: regionID, laneID: laneID, frame: frame, gesture: value, geometoryProxy: proxy, lanePreferences: preferenceValue) { value in
                                    withAnimation(.interactiveSpring(response: 0.1, dampingFraction: 0.6, blendDuration: 0)) {
                                        selection.wrappedValue = value
                                    }
                                }
                        }
                )
        }
    }
}
