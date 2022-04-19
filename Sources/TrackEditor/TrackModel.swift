//
//  TrackModel.swift
//  
//
//  Created by nori on 2022/04/19.
//

import Foundation
import SwiftUI

final class TrackModel: ObservableObject {

    var options: TrackOptions = TrackOptions()

    var laneRange: Range<Int> = 0..<100

    func onDragGestureEnded(id: String?, gesture: DragGesture.Value, geometoryProxy: GeometryProxy, preferenceValue: [LanePreference], perform: @escaping (RegionSelection) -> Void) {

        let options = self.options
        let laneRange = self.laneRange
        let locationX = gesture.location.x - options.headerWidth
        let lowerBound = Int(round((locationX - options.barWidth / 2) / options.barWidth))
        let upperBound = Int(round((locationX + options.barWidth / 2) / options.barWidth))
        let range = lowerBound..<upperBound

        if let index = preferenceValue.firstIndex(where: { preference in
            let frame = geometoryProxy[preference.bounds]
            return frame.contains(gesture.location)
        }) {
            let preference = preferenceValue[index]
            let laneID = preference.id
            let regionAddress = RegionAddress(id: laneID, range: range)
            let moveAction: RegionMoveAction = RegionMoveAction { address in
                guard let preference = preferenceValue[address.id] else { return }
                let laneFrame = geometoryProxy[preference.bounds]
                let width = CGFloat(address.range.upperBound - address.range.lowerBound) * options.barWidth
                let height = options.trackHeight
                let size = CGSize(width: width, height: height)
                let positionX = CGFloat(address.range.lowerBound - laneRange.lowerBound) * options.barWidth + options.headerWidth
                let position = CGPoint(x: positionX, y: laneFrame.midY)
                let period = CGFloat(address.range.lowerBound)..<CGFloat(address.range.upperBound)
                perform(RegionSelection(id: id, laneID: address.id, position: position, size: size, offset: .zero, period: period, state: .focused))
            }
            if let onTrackGestureEneded = onTrackGestureEneded {
                onTrackGestureEneded(regionAddress, moveAction)
            }
        }
    }

    var onTrackGestureChanged: (() -> Void)?
    var onTrackGestureEneded: ((RegionAddress, RegionMoveAction) -> Void)?
}
