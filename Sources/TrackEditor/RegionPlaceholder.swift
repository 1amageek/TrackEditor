//
//  RegionPlaceholder.swift
//  
//
//  Created by nori on 2022/04/14.
//

import SwiftUI

public struct RegionPlaceholder: Identifiable {

    public struct HideAction {

        var action: () -> Void

        init(_ action: @escaping () -> Void) {
            self.action = action
        }

        public func callAsFunction() {
            self.action()
        }
    }

    public var id: String

    public var period: Range<Int>

    public var action: HideAction

    public init(period: Range<Int>, action: @escaping () -> Void) {
        self.id = UUID().uuidString
        self.period = period
        self.action = HideAction(action)
    }

    public func hide() {
        self.action()
    }
}

extension RegionPlaceholder: LaneRegioning {

    public func startRegion(_ laneRange: Range<Int>, options: TrackEditorOptions) -> CGFloat {
        CGFloat(period.lowerBound)
    }

    public func endRegion(_ laneRange: Range<Int>, options: TrackEditorOptions) -> CGFloat {
        CGFloat(period.upperBound)
    }
}


//struct PlacehoderRegion_Previews: PreviewProvider {
//    static var previews: some View {
//        PlacehoderRegion()
//    }
//}
