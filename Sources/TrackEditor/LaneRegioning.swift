//
//  LaneRegioning.swift
//  
//
//  Created by nori on 2022/04/10.
//

import Foundation
import CoreGraphics

public protocol LaneRegioning {
    func startRegion(_ laneRange: Range<Int>, options: TrackEditorOptions) -> CGFloat
    func endRegion(_ laneRange: Range<Int>, options: TrackEditorOptions) -> CGFloat
}
