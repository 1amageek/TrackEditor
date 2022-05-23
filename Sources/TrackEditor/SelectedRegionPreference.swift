//
//  SelectedRegionPreference.swift
//  
//
//  Created by nori on 2022/05/23.
//

import Foundation
import SwiftUI

public struct SelectedRegionPreference: Identifiable, Hashable {

    public var id: String?

    public var laneID: String

    public var bounds: Anchor<CGRect>

    init(id: String?, laneID: String, bounds: Anchor<CGRect>) {
        self.id = id
        self.laneID = laneID
        self.bounds = bounds
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(laneID)
    }
}

public struct SelectedRegionPreferenceKey: PreferenceKey {

    public static var defaultValue: SelectedRegionPreference?

    public static func reduce(value: inout SelectedRegionPreference?, nextValue: () -> SelectedRegionPreference?) {
        value = nextValue()
    }
}
