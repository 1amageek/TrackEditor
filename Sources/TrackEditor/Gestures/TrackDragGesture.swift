//
//  TrackDragGesture.swift
//  
//
//  Created by nori on 2022/04/21.
//

import SwiftUI

struct TrackDragGesture: Gesture {

    @EnvironmentObject var model: Model

    @Environment(\.laneRange) var laneRange: Range<Int>

    @Environment(\.trackOptions) var options: TrackOptions

    @Environment(\.selection) var selection: Binding<RegionSelection?>

    @Environment(\.onTrackTapGesture) var onTrackTapGesture: ((RegionSelection?) -> Void)?

    @Environment(\.onTrackDragGestureChanged) var onTrackDragGestureChanged: (() -> Void)?

    @Environment(\.onTrackDragGestureEnded) var onTrackDragGestureEnded: ((RegionAddress, RegionMoveAction) -> Void)?

    @Environment(\.trackNamespace) var trackNamespace: Namespace

    var geometory: GeometryProxy { model.geometory! }

    var preferenceValue: [LanePreference] { model.lanePreferences }

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

    var body: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                if let selection = selection.wrappedValue, selection.gestureState != .focused {
                    let laneID = selection.laneID
                    let x = value.startLocation.x - options.barWidth / 2
                    let y = value.startLocation.y - options.trackHeight / 2
                    var frame = CGRect(x: x, y: y, width: selection.changes.after.size.width, height: selection.changes.after.size.height)
                    if let id = selection.id, let regionPreference = preferenceValue[laneID]?.regionPreferences[id] {
                        frame = geometory[regionPreference.bounds]
                    }
                    TrackGestureHandler(laneRange: laneRange, options: options, regionSelection: selection, onTrackDragGestureChanged: onTrackDragGestureChanged, onTrackDragGestureEnded: onTrackDragGestureEnded)
                        .onDragGestureChanged(id: selection.id, laneID: laneID, frame: frame, gesture: value, geometoryProxy: geometory) { value in
                            self.selection.wrappedValue = value
                        }
                } else {
                    guard let laneID = getLanePreference(value: value, geometory: geometory, preferenceValue: preferenceValue)?.id else { return }
                    var id: String? = nil
                    let x = value.startLocation.x - options.barWidth / 2
                    let y = value.startLocation.y - options.trackHeight / 2
                    var frame = CGRect(x: x, y: y, width: options.barWidth, height: options.trackHeight)
                    if let regionPreference = getRegionPreference(value: value, geometory: geometory, preferenceValue: preferenceValue) {
                        id = regionPreference.id
                        frame = geometory[regionPreference.bounds]
                    }
                    TrackGestureHandler(laneRange: laneRange, options: options, regionSelection: nil, onTrackDragGestureChanged: onTrackDragGestureChanged, onTrackDragGestureEnded: onTrackDragGestureEnded)
                        .onDragGestureChanged(id: id, laneID: laneID, frame: frame, gesture: value, geometoryProxy: geometory) { value in
                            self.selection.wrappedValue = value
                        }
                }
            }
            .onEnded { value in
                if let selection = selection.wrappedValue, selection.gestureState != .focused {
                    let frame = CGRect(x: value.startLocation.x - options.barWidth / 2, y: value.startLocation.y, width: selection.changes.after.size.width, height: selection.changes.after.size.height)
                    TrackGestureHandler(laneRange: laneRange, options: options, regionSelection: selection, onTrackDragGestureChanged: onTrackDragGestureChanged, onTrackDragGestureEnded: onTrackDragGestureEnded)
                        .onDragGestureEnded(id: selection.id, laneID: selection.laneID, frame: frame, gesture: value, geometoryProxy: geometory, lanePreferences: preferenceValue) { value in
                            withAnimation(.interactiveSpring(response: 0.1, dampingFraction: 0.6, blendDuration: 0)) {
                                self.selection.wrappedValue = value
                            }
                        }
                } else {
                    selection.wrappedValue = nil
                }
            }
    }
}
