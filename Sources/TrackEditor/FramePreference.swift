//
//  FramePreference.swift
//  
//
//  Created by nori on 2022/04/13.
//

import SwiftUI

struct FramePreference: Hashable {
    var trackID: String
    var index: Int
    var bounds: Anchor<CGRect>

    func hash(into hasher: inout Hasher) {
        hasher.combine(trackID)
        hasher.combine(index)
    }
}

struct FramePreferenceKey: PreferenceKey {

    static var defaultValue: [FramePreference] = []

    static func reduce(value: inout [FramePreference], nextValue: () -> [FramePreference]) {
        value = nextValue()
    }
}
