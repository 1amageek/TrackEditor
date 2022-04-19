//
//  LaneDragGestureBackground.swift
//  
//
//  Created by nori on 2022/04/18.
//

import SwiftUI

struct LaneDragGestureBackground: View {

    @Environment(\.laneRange) var laneRange: Range<Int>

    @Environment(\.trackOptions) var options: TrackOptions

    @Environment(\.selection) var selection: Binding<RegionSelection?>

    @Environment(\.onRegionDragGestureChanged) var onRegionDragGestureChanged: (() -> Void)?

    @Environment(\.onRegionDragGestureEnded) var onRegionDragGestureEnded: ((RegionAddress, RegionMoveAction) -> Void)?

    @Environment(\.trackNamespace) var trackNamespace: Namespace

    func period(for frame: CGRect) -> Range<CGFloat> {
        let start = round((frame.minX - options.headerWidth) / options.barWidth)
        let end = round((frame.maxX - options.headerWidth) / options.barWidth)
        return start..<end
    }

    var laneID: AnyHashable

    var preferenceValue: [LanePreference]

    func getLanePreference(value: DragGesture.Value, geometory: GeometryProxy, preferenceValue: [LanePreference]) -> LanePreference? {
        if let index = preferenceValue.firstIndex(where: { lanePrefrence in
            let frame = geometory[lanePrefrence.bounds]
            return frame.contains(value.location)
        }) {
            let lanePrefrence = preferenceValue[index]
            return lanePrefrence
        }
        return nil
    }

    func getRegionPreference(value: DragGesture.Value, geometory: GeometryProxy, preferenceValue: [LanePreference]) -> RegionPreference? {
        guard let lanePreference = getLanePreference(value: value, geometory: geometory, preferenceValue: preferenceValue) else { return nil }
        let regionPreferences = lanePreference.regionPreferences
        if let index = regionPreferences.firstIndex(where: { regionPreference in
            let frame = geometory[regionPreference.bounds]
            return frame.contains(value.location)
        }) {
            let regionPreference = regionPreferences[index]
            return regionPreference
        }
        return nil
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
                            if let selection = selection.wrappedValue, selection.state != .focused {
                                var frame = CGRect(x: value.startLocation.x - options.barWidth / 2, y: value.startLocation.y, width: selection.size.width, height: selection.size.height)
                                if let id = selection.id, let regionPreference = preferenceValue[laneID]?.regionPreferences[id] {
                                    frame = proxy[regionPreference.bounds].offsetBy(dx: 0, dy: options.rulerHeight)
                                }
                                LaneDragGestureHandler(laneRange: laneRange, options: options, onRegionDragGestureChanged: onRegionDragGestureChanged, onRegionDragGestureEnded: onRegionDragGestureEnded)
                                    .onDragGestureChanged(frame: frame, gesture: value, geometoryProxy: proxy) { frame, offset, period in
                                        self.selection.wrappedValue = RegionSelection(id: selection.id, laneID: laneID, position: CGPoint(x: frame.midX, y: frame.midY), size: frame.size, offset: offset, period: period, state: .dragging)
                                    }
                            } else {
                                var id: AnyHashable? = nil
                                var frame = CGRect(x: value.startLocation.x - options.barWidth / 2, y: value.startLocation.y, width: options.barWidth, height: options.trackHeight)
                                if let regionPreference = getRegionPreference(value: value, geometory: proxy, preferenceValue: preferenceValue) {
                                    id = regionPreference.id
                                    frame = proxy[regionPreference.bounds].offsetBy(dx: 0, dy: options.rulerHeight)
                                }
                                LaneDragGestureHandler(laneRange: laneRange, options: options, onRegionDragGestureChanged: onRegionDragGestureChanged, onRegionDragGestureEnded: onRegionDragGestureEnded)
                                    .onDragGestureChanged(frame: frame, gesture: value, geometoryProxy: proxy) { frame, offset, period in
                                        self.selection.wrappedValue = RegionSelection(id: id, laneID: laneID, position: CGPoint(x: frame.midX, y: frame.midY), size: frame.size, offset: offset, period: period, state: .dragging)
                                    }
                            }
                        }
                        .onEnded { value in
                            if let selection = selection.wrappedValue, selection.state != .focused {
                                let frame = CGRect(x: value.startLocation.x - options.barWidth / 2, y: value.startLocation.y - options.trackHeight / 2, width: options.barWidth, height: options.trackHeight)
                                LaneDragGestureHandler(laneRange: laneRange, options: options, onRegionDragGestureChanged: onRegionDragGestureChanged, onRegionDragGestureEnded: onRegionDragGestureEnded)
                                    .onDragGestureEnded(id: selection.id, laneID: selection.laneID, frame: frame, gesture: value, geometoryProxy: proxy, lanePreferences: preferenceValue) { value in
                                        withAnimation(.interactiveSpring(response: 0.1, dampingFraction: 0.6, blendDuration: 0)) {
                                            self.selection.wrappedValue = value
                                        }
                                    }
                            } else {
                                selection.wrappedValue = nil
                            }
                        }
                )
        }
    }
}
