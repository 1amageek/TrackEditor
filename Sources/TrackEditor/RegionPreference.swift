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

    var laneID: AnyHashable

    var bounds: Anchor<CGRect>

    init(id: AnyHashable, laneID: AnyHashable, bounds: Anchor<CGRect>) {
        self.id = id
        self.laneID = laneID
        self.bounds = bounds
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(laneID)
    }
}

struct RegionPreferenceKey: PreferenceKey {

    static var defaultValue: [RegionPreference] = []

    static func reduce(value: inout [RegionPreference], nextValue: () -> [RegionPreference]) {
        value += nextValue()
    }
}

extension Array where Element == RegionPreference {

    subscript<V>(_ id: V) -> RegionPreference? where V: Hashable {
        get {
            self.first(where: { $0.id == AnyHashable(id) })
        }
        set {
            if let newValue = newValue,
               let index = self.firstIndex(where: { $0.id == AnyHashable(id) }) {
                self[index] = newValue
            }
        }
    }
}
