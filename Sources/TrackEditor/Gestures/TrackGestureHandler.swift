//
//  TrackGestureHandler.swift
//  
//
//  Created by nori on 2022/04/19.
//

import SwiftUI

struct TrackGestureHandler {

    var options: TrackOptions

    var laneRange: Range<Int>

    var regionSelection: RegionSelection?

    var onTrackDragGestureChanged: (() -> Void)?

    var onTrackDragGestureEnded: ((RegionAddress, RegionMoveAction) -> Void)?

    init(
        laneRange: Range<Int>,
        options: TrackOptions,
        regionSelection: RegionSelection?,
        onTrackDragGestureChanged: (() -> Void)? = nil,
        onTrackDragGestureEnded: ((RegionAddress, RegionMoveAction) -> Void)? = nil
    ) {
        self.laneRange = laneRange
        self.options = options
        self.regionSelection = regionSelection
        self.onTrackDragGestureChanged = onTrackDragGestureChanged
        self.onTrackDragGestureEnded = onTrackDragGestureEnded
    }

    func makeRegionSelection(regionID: String?, address: RegionAddress, geometoryProxy: GeometryProxy, lanePreferences: [LanePreference]) -> RegionSelection? {
        guard let preference = lanePreferences[address.id] else { return nil }
        let laneFrame = geometoryProxy[preference.bounds]
        let width = CGFloat(address.range.count) * options.barWidth
        let height = options.trackHeight
        let size = CGSize(width: width, height: height)
        let positionX = CGFloat(address.range.lowerBound - laneRange.lowerBound) * options.barWidth + options.headerWidth + width / 2
        let pssitionY = laneFrame.midY
        let position = CGPoint(x: positionX, y: pssitionY)
        let period = CGFloat(address.range.lowerBound)..<CGFloat(address.range.upperBound)
        let currentState: RegionSelection.State = RegionSelection.State(position: position, size: size, offset: .zero)
        let startState = regionSelection?.startState ?? currentState
        return RegionSelection(id: regionID, laneID: address.id, startState: startState, changes: (currentState, currentState), period: period, gestureState: .focused)
    }

    func onTapGesture() -> Void {
        
    }

    func onDragGestureChanged(id: String?, laneID: String, frame: CGRect, gesture: DragGesture.Value, geometoryProxy: GeometryProxy, perform: @escaping (RegionSelection) -> Void) {
        let translateFrame = frame.offsetBy(dx: gesture.translation.width, dy: gesture.translation.height)
        let translatePosition = translateFrame.origin
        let offset = gesture.translation
        let lowerBound = round((translatePosition.x) / translateFrame.width)
        let upperBound = round((translatePosition.x + translateFrame.width) / translateFrame.width)
        let period = lowerBound..<upperBound
        let currentState: RegionSelection.State = RegionSelection.State(position: CGPoint(x: frame.midX, y: frame.midY), size: frame.size, offset: offset)
        let startState = regionSelection?.startState ?? currentState
        let before = regionSelection?.changes.before ?? currentState
        let selection = RegionSelection(id: id, laneID: laneID, startState: startState, changes: (before, currentState), period: period, gestureState: .dragging)
        perform(selection)
    }

    func onDragGestureEnded(id: String?, laneID: String, frame: CGRect, gesture: DragGesture.Value, geometoryProxy: GeometryProxy, lanePreferences: [LanePreference], perform: @escaping (RegionSelection) -> Void) {
        let translateFrame = frame.offsetBy(dx: gesture.translation.width, dy: gesture.translation.height)
        let x: CGFloat = max(translateFrame.minX - options.headerWidth, 0)
        let y: CGFloat = max(translateFrame.minY - options.rulerHeight, 0)
        let position = CGPoint(x: x, y: y)
        let lowerBound = Int(round((position.x) / options.barWidth)) + laneRange.lowerBound
        let upperBound = Int(round((position.x + translateFrame.width) / options.barWidth)) + laneRange.lowerBound
        let range = lowerBound..<upperBound
        if let index = lanePreferences.firstIndex(where: { preference in
            let frame = geometoryProxy[preference.bounds]
            return frame.contains(gesture.location)
        }) {
            let preference = lanePreferences[index]
            let laneID = preference.id
            let regionAddress = RegionAddress(id: laneID, range: range)
            let moveAction: RegionMoveAction = RegionMoveAction { address in
                guard let selection = makeRegionSelection(regionID: id, address: address, geometoryProxy: geometoryProxy, lanePreferences: lanePreferences) else { return }
                perform(selection)
            }
            if let onTrackDragGestureEnded = onTrackDragGestureEnded {
                onTrackDragGestureEnded(regionAddress, moveAction)
            } else {
                moveAction(address: regionAddress)
            }
        } else {
            let regionAddress = RegionAddress(id: laneID, range: range)
            let moveAction: RegionMoveAction = RegionMoveAction { address in
                guard let selection = makeRegionSelection(regionID: id, address: address, geometoryProxy: geometoryProxy, lanePreferences: lanePreferences) else { return }
                perform(selection)
            }
            if let onTrackDragGestureEnded = onTrackDragGestureEnded {
                onTrackDragGestureEnded(regionAddress, moveAction)
            } else {
                moveAction(address: regionAddress)
            }
        }
    }

    func onEdgeDragGestureChanged(id: String?, laneID: String, frame: CGRect, gesture: DragGesture.Value, geometoryProxy: GeometryProxy, perform: @escaping (RegionSelection) -> Void) {
        let lowerBound = round((frame.minX - options.headerWidth) / options.barWidth)
        let upperBound = round((frame.maxX - options.headerWidth) / options.barWidth)
        let period = lowerBound..<upperBound
        let currentState: RegionSelection.State = RegionSelection.State(position: CGPoint(x: frame.midX, y: frame.midY), size: frame.size, offset: .zero)
        let startState = regionSelection?.startState ?? currentState
        let before = regionSelection?.changes.before ?? currentState
        let selection = RegionSelection(id: id, laneID: laneID, startState: startState, changes: (before, currentState), period: period, gestureState: .edgeDragging)
        perform(selection)
    }

    func onEdgeDragGestureEnded(id: String?, laneID: String, frame: CGRect, gesture: DragGesture.Value, geometoryProxy: GeometryProxy, lanePreferences: [LanePreference], perform: @escaping (RegionSelection) -> Void) {
        let lowerBound = Int(round((frame.minX - options.headerWidth) / options.barWidth)) + laneRange.lowerBound
        let upperBound = Int(round((frame.maxX - options.headerWidth) / options.barWidth)) + laneRange.lowerBound
        let period = lowerBound..<upperBound
        let regionAddress = RegionAddress(id: laneID, range: period)
        let moveAction: RegionMoveAction = RegionMoveAction { address in
            guard let selection = makeRegionSelection(regionID: id, address: address, geometoryProxy: geometoryProxy, lanePreferences: lanePreferences) else { return }
            perform(selection)
        }
        if let onTrackDragGestureEnded = onTrackDragGestureEnded {
            onTrackDragGestureEnded(regionAddress, moveAction)
        } else {
            moveAction(address: regionAddress)
        }
    }
}
