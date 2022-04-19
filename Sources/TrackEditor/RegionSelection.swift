//
//  RegionSelection.swift
//  
//
//  Created by nori on 2022/04/16.
//

import SwiftUI


public enum TrackGestureState: Hashable {
    case focused
    case pressing
    case dragging
}

public struct RegionSelection: Hashable {
    public var id: AnyHashable?
    public var laneID: AnyHashable
    public var position: CGPoint
    public var size: CGSize
    public var offset: CGSize
    public var period: Range<CGFloat>
    public var state: TrackGestureState

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(laneID)
        hasher.combine(position.x)
        hasher.combine(position.y)
        hasher.combine(size.width)
        hasher.combine(size.height)
        hasher.combine(offset.width)
        hasher.combine(offset.height)
        hasher.combine(period)
        hasher.combine(state)
    }
}

extension Binding: Equatable where Value == RegionSelection? {
    public static func == (lhs: Binding<Value>, rhs: Binding<Value>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

