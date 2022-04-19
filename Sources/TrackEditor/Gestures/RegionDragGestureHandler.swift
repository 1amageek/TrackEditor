//
//  RegionDragGestureHandler.swift
//  
//
//  Created by nori on 2022/04/19.
//

import SwiftUI

struct RegionDragGestureHandler {

    var options: TrackOptions

    var laneRange: Range<Int>

    var onRegionDragGestureChanged: (() -> Void)?

    var onRegionDragGestureEnded: ((RegionAddress, RegionMoveAction) -> Void)?

    init(laneRange: Range<Int>, options: TrackOptions, onRegionDragGestureChanged: (() -> Void)? = nil, onRegionDragGestureEnded: ((RegionAddress, RegionMoveAction) -> Void)? = nil) {
        self.laneRange = laneRange
        self.options = options
        self.onRegionDragGestureChanged = onRegionDragGestureChanged
        self.onRegionDragGestureEnded = onRegionDragGestureEnded
    }

    func onDragGestureChanged(frame: CGRect, gesture: DragGesture.Value, geometoryProxy: GeometryProxy, perform: @escaping (CGRect, CGSize, Range<CGFloat>) -> Void) {
        let translateFrame = frame.offsetBy(dx: gesture.translation.width, dy: gesture.translation.height)
        let translatePosition = translateFrame.origin
        let lowerBound = round((translatePosition.x) / translateFrame.width)
        let upperBound = round((translatePosition.x + translateFrame.width) / translateFrame.width)
        let period = lowerBound..<upperBound
        perform(frame, gesture.translation, period)
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
                perform(RegionSelection(id: id, laneID: address.id, position: position, size: size, offset: .zero, period: period, state: .focused))
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
                print("w", address.range.lowerBound, laneRange.lowerBound)
                let positionX = CGFloat(address.range.lowerBound - laneRange.lowerBound) * options.barWidth + options.headerWidth + width / 2
                let pssitionY = laneFrame.midY + options.rulerHeight
                let position = CGPoint(x: positionX, y: pssitionY)
                let period = CGFloat(address.range.lowerBound)..<CGFloat(address.range.upperBound)
                perform(RegionSelection(id: id, laneID: address.id, position: position, size: size, offset: .zero, period: period, state: .focused))
            }
            if let onRegionDragGestureEnded = onRegionDragGestureEnded {
                onRegionDragGestureEnded(regionAddress, moveAction)
            } else {
                moveAction(address: regionAddress)
            }
        }
    }
}
