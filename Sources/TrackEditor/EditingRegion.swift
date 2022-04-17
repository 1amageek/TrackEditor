//
//  EditingRegion.swift
//  
//
//  Created by nori on 2022/04/16.
//

import SwiftUI


public enum EditingGestureState: Hashable {
    case focused
    case pressing
    case dragging
}

public struct EditingSelection: Hashable {
    public var id: String?
    public var position: CGPoint
    public var size: CGSize
    public var period: Range<CGFloat>
    public var state: EditingGestureState

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(position.x)
        hasher.combine(position.y)
        hasher.combine(size.width)
        hasher.combine(size.height)
        hasher.combine(period)
        hasher.combine(state)
    }
}

extension Binding: Equatable where Value == EditingSelection? {
    public static func == (lhs: Binding<Value>, rhs: Binding<Value>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

