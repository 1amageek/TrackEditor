//
//  RegionEdgeDragGestureOverlay.swift
//  
//
//  Created by nori on 2022/04/20.
//

import SwiftUI

struct RegionEdgeDragGestureOverlay: View {

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
    
    var body: some View {
        if let selection = selection.wrappedValue {
            GeometryReader { proxy in
                HStack(spacing: 0) {
                    Spacer()
                    Color.clear
                        .contentShape(Rectangle())
                        .frame(width: 24)
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .named(trackNamespace.wrappedValue))
                                .onChanged { value in
                                    let before = selection.changes.before
                                    let x = before.position.x - before.size.width / 2
                                    let y = before.position.y - before.size.height / 2
                                    let width = max(before.size.width + value.translation.width, options.barWidth)
                                    let frame = CGRect(x: x, y: y, width: width, height: before.size.height)
                                    TrackGestureHandler(laneRange: laneRange, options: options, regionSelection: selection, onTrackDragGestureChanged: onTrackDragGestureChanged, onTrackDragGestureEnded: onTrackDragGestureEnded)
                                        .onEdgeDragGestureChanged(id: regionID, laneID: laneID, frame: frame, gesture: value, geometoryProxy: trackGeometory) { value in
                                            withAnimation(.interactiveSpring(response: 0.1, dampingFraction: 0.6, blendDuration: 0)) {
                                                self.selection.wrappedValue = value
                                            }
                                        }
                                }
                                .onEnded { value in
                                    let before = selection.changes.before
                                    let x = before.position.x - before.size.width / 2
                                    let y = before.position.y - before.size.height / 2
                                    let width = max(before.size.width + value.translation.width, options.barWidth)
                                    let frame = CGRect(x: x, y: y, width: width, height: before.size.height)
                                    TrackGestureHandler(laneRange: laneRange, options: options, regionSelection: selection, onTrackDragGestureChanged: onTrackDragGestureChanged, onTrackDragGestureEnded: onTrackDragGestureEnded)
                                        .onEdgeDragGestureEnded(id: regionID, laneID: laneID, frame: frame, gesture: value, geometoryProxy: trackGeometory, lanePreferences: preferenceValue) { value in
                                            withAnimation(.interactiveSpring(response: 0.1, dampingFraction: 0.6, blendDuration: 0)) {
                                                self.selection.wrappedValue = value
                                            }
                                        }
                                }
                        )
                }
            }
        }
    }
}
