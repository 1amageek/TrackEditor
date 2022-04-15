//
//  RegionPreference.swift
//  
//
//  Created by nori on 2022/04/15.
//

import Foundation
import SwiftUI

struct RegionPreference: Identifiable, Hashable {

    var id: AnyHashable

    var bounds: Anchor<CGRect>

    init(id: AnyHashable, bounds: Anchor<CGRect>) {
        self.id = id
        self.bounds = bounds
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct RegionPreferenceKey: PreferenceKey {

    static var defaultValue: [RegionPreference] = []

    static func reduce(value: inout [RegionPreference], nextValue: () -> [RegionPreference]) {
        value += nextValue()
    }
}
