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
    case edgeDragging
}

public struct RegionSelection: Hashable {

    public var id: AnyHashable?
    public var laneID: AnyHashable
    public var startState: State
    public var changes: (before: State, after: State)
    public var period: Range<CGFloat>
    public var gestureState: TrackGestureState

    init(id: AnyHashable? = nil, laneID: AnyHashable, startState: RegionSelection.State, changes: (before: State, after: State), period: Range<CGFloat>, gestureState: TrackGestureState) {
        self.id = id
        self.laneID = laneID
        self.startState = startState
        self.changes = changes
        self.period = period
        self.gestureState = gestureState
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(laneID)
        hasher.combine(changes.after)
        hasher.combine(gestureState)
    }

    public static func == (lhs: RegionSelection, rhs: RegionSelection) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

extension RegionSelection {

    public struct State: Hashable {
        public var position: CGPoint
        public var size: CGSize
        public var offset: CGSize
        public func hash(into hasher: inout Hasher) {
            hasher.combine(position.x)
            hasher.combine(position.y)
            hasher.combine(size.width)
            hasher.combine(size.height)
            hasher.combine(offset.width)
            hasher.combine(offset.height)
        }
    }
}

extension Binding: Equatable where Value == RegionSelection? {
    public static func == (lhs: Binding<Value>, rhs: Binding<Value>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

