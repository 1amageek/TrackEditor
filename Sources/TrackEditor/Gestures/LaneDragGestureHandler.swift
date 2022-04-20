//
//  LaneDragGestureHandler.swift
//  
//
//  Created by nori on 2022/04/19.
//

import SwiftUI

struct LaneDragGestureHandler {

    var options: TrackOptions

    var laneRange: Range<Int>

    var regionSelection: RegionSelection?

    var onRegionDragGestureChanged: (() -> Void)?

    var onRegionDragGestureEnded: ((RegionAddress, RegionMoveAction) -> Void)?

    init(
        laneRange: Range<Int>,
        options: TrackOptions,
        regionSelection: RegionSelection?,
        onRegionDragGestureChanged: (() -> Void)? = nil,
        onRegionDragGestureEnded: ((RegionAddress, RegionMoveAction) -> Void)? = nil
    ) {
        self.laneRange = laneRange
        self.options = options
        self.regionSelection = regionSelection
        self.onRegionDragGestureChanged = onRegionDragGestureChanged
        self.onRegionDragGestureEnded = onRegionDragGestureEnded
    }

    func onDragGestureChanged(id: AnyHashable?, laneID: AnyHashable, frame: CGRect, gesture: DragGesture.Value, geometoryProxy: GeometryProxy, perform: @escaping (RegionSelection) -> Void) {
        let translateFrame = frame.offsetBy(dx: gesture.translation.width, dy: gesture.translation.height)
        let translatePosition = translateFrame.origin
        let offset = gesture.translation
        let lowerBound = round((translatePosition.x) / translateFrame.width)
        let upperBound = round((translatePosition.x + translateFrame.width) / translateFrame.width)
        let period = lowerBound..<upperBound
        let currentState: RegionSelection.State = RegionSelection.State(position: CGPoint(x: frame.midX, y: frame.midY), size: frame.size, offset: offset)
        let startState = regionSelection?.startState ?? currentState
        let selection = RegionSelection(id: id, laneID: laneID, startState: startState, currentState: currentState, period: period, gestureState: .dragging)
        perform(selection)
    }

    func onDragGestureEnded(id: AnyHashable?, laneID: AnyHashable, frame: CGRect, gesture: DragGesture.Value, geometoryProxy: GeometryProxy, lanePreferences: [LanePreference], perform: @escaping (RegionSelection) -> Void) {
        let translateFrame = frame.offsetBy(dx: gesture.translation.width, dy: gesture.translation.height)
        let position = CGPoint(x: translateFrame.minX - options.headerWidth, y: translateFrame.minY  - options.rulerHeight)
        let lowerBound = Int(round((position.x) / options.barWidth))
        let upperBound = Int(round((position.x + translateFrame.width) / options.barWidth))
        let range = lowerBound..<upperBound
        if let index = lanePreferences.firstIndex(where: { preference in
            let frame = geometoryProxy[preference.bounds]
            return frame.contains(gesture.location)
        }) {
            let preference = lanePreferences[index]
            let laneID = preference.id
            let regionAddress = RegionAddress(id: laneID, range: range)
            let moveAction: RegionMoveAction = RegionMoveAction { address in
                guard let preference = lanePreferences[address.id] else { return }
                let laneFrame = geometoryProxy[preference.bounds]
                let width = CGFloat(address.range.count) * options.barWidth
                let height = options.trackHeight
                let size = CGSize(width: width, height: height)
                let positionX = CGFloat(address.range.lowerBound - laneRange.lowerBound) * options.barWidth + options.headerWidth + width / 2
                let pssitionY = laneFrame.midY + options.rulerHeight
                let position = CGPoint(x: positionX, y: pssitionY)
                let period = CGFloat(address.range.lowerBound)..<CGFloat(address.range.upperBound)

                let currentState: RegionSelection.State = RegionSelection.State(position: position, size: size, offset: .zero)
                let startState = regionSelection?.startState ?? currentState
                let selection = RegionSelection(id: id, laneID: address.id, startState: startState, currentState: currentState, period: period, gestureState: .focused)
                perform(selection)
            }
            if let onRegionDragGestureEnded = onRegionDragGestureEnded {
                onRegionDragGestureEnded(regionAddress, moveAction)
            } else {
                moveAction(address: regionAddress)
            }
        } else {
            let regionAddress = RegionAddress(id: laneID, range: range)
            let moveAction: RegionMoveAction = RegionMoveAction { address in
                guard let preference = lanePreferences[address.id] else { return }
                let laneFrame = geometoryProxy[preference.bounds]
                let width = CGFloat(address.range.count) * options.barWidth
                let height = options.trackHeight
                let size = CGSize(width: width, height: height)
                let positionX = CGFloat(address.range.lowerBound - laneRange.lowerBound) * options.barWidth + options.headerWidth + width / 2
                let pssitionY = laneFrame.midY + options.rulerHeight
                let position = CGPoint(x: positionX, y: pssitionY)
                let period = CGFloat(address.range.lowerBound)..<CGFloat(address.range.upperBound)

                let currentState: RegionSelection.State = RegionSelection.State(position: position, size: size, offset: .zero)
                let startState = regionSelection?.startState ?? currentState
                let selection = RegionSelection(id: id, laneID: address.id, startState: startState, currentState: currentState, period: period, gestureState: .focused)
                perform(selection)
            }
            if let onRegionDragGestureEnded = onRegionDragGestureEnded {
                onRegionDragGestureEnded(regionAddress, moveAction)
            } else {
                moveAction(address: regionAddress)
            }
        }
    }
}
