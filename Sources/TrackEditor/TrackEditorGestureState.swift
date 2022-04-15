//
//  TrackEditorGestureState.swift
//  
//
//  Created by nori on 2022/04/13.
//

import Foundation
import CoreGraphics
import SwiftUI

enum TrackEditorGestureState {

    case inactive
    case pressing
    case dragging(id: AnyHashable?, dragGesture: DragGesture.Value, frame: CGRect)

    var id: AnyHashable? {
        switch self {
            case .inactive, .pressing:
                return nil
            case .dragging(let id, _, _):
                return id
        }
    }

    var frame: CGRect {
        switch self {
            case .inactive, .pressing:
                return .zero
            case .dragging(_, _, let frame):
                return frame
        }
    }

    var translation: CGSize {
        switch self {
            case .inactive, .pressing:
                return .zero
            case .dragging(_, let dragGesture, _):
                return dragGesture.translation
        }
    }

    var startLocation: CGPoint {
        switch self {
            case .inactive, .pressing:
                return .zero
            case .dragging(_, let dragGesture, _):
                return dragGesture.startLocation
        }
    }

    var isActive: Bool {
        switch self {
            case .inactive:
                return false
            case .pressing, .dragging:
                return true
        }
    }

    var isDragging: Bool {
        switch self {
            case .inactive, .pressing:
                return false
            case .dragging:
                return true
        }
    }
}
