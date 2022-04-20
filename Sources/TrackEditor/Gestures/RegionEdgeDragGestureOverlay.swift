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

    @Environment(\.onRegionDragGestureChanged) var onRegionDragGestureChanged: (() -> Void)?

    @Environment(\.onRegionDragGestureEnded) var onRegionDragGestureEnded: ((RegionAddress, RegionMoveAction) -> Void)?

    @Environment(\.trackNamespace) var namespace: Namespace

    var regionID: AnyHashable?

    var laneID: AnyHashable

    var preferenceValue: [LanePreference]
    
    var body: some View {
        if let selection = selection.wrappedValue {
            GeometryReader { proxy in
                HStack(spacing: 0) {
                    Spacer()
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 28)
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                                .onChanged { value in
                                    let before = selection.changes.before
                                    let x = before.position.x - before.size.width / 2
                                    let y = before.position.y - before.size.height / 2
                                    let width = max(before.size.width + value.translation.width, options.barWidth)
                                    let frame = CGRect(x: x, y: y, width: width, height: before.size.height)
                                    LaneDragGestureHandler(laneRange: laneRange, options: options, regionSelection: selection, onRegionDragGestureChanged: onRegionDragGestureChanged, onRegionDragGestureEnded: onRegionDragGestureEnded)
                                        .onEdgeDragGestureChanged(id: regionID, laneID: laneID, frame: frame, gesture: value, geometoryProxy: proxy) { value in
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
                                    LaneDragGestureHandler(laneRange: laneRange, options: options, regionSelection: selection, onRegionDragGestureChanged: onRegionDragGestureChanged, onRegionDragGestureEnded: onRegionDragGestureEnded)
                                        .onEdgeDragGestureEnded(id: regionID, laneID: laneID, frame: frame, gesture: value, geometoryProxy: proxy, lanePreferences: preferenceValue) { value in
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
