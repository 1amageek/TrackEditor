//
//  TrackEditorGestureState.swift
//  
//
//  Created by nori on 2022/04/13.
//

import Foundation
import CoreGraphics

enum TrackEditorGestureState {

    case inactive
    case pressing
    case dragging(translation: CGSize, startLocation: CGPoint)

    var translation: CGSize {
        switch self {
            case .inactive, .pressing:
                return .zero
            case .dragging(let translation, _):
                return translation
        }
    }

    var startLocation: CGPoint {
        switch self {
            case .inactive, .pressing:
                return .zero
            case .dragging(_, let startLocation):
                return startLocation
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
