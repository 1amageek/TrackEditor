//
//  LanePreference.swift
//  
//
//  Created by nori on 2022/04/18.
//

import Foundation
import SwiftUI

struct LanePreference: Identifiable, Hashable {

    var id: String

    var bounds: Anchor<CGRect>

    var regionPreferences: [RegionPreference]

    init(id: String, bounds: Anchor<CGRect>, regionPreferences: [RegionPreference]) {
        self.id = id
        self.bounds = bounds
        self.regionPreferences = regionPreferences
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct LanePreferenceKey: PreferenceKey {

    static var defaultValue: [LanePreference] = []

    static func reduce(value: inout [LanePreference], nextValue: () -> [LanePreference]) {
        value += nextValue()
    }
}

extension Array where Element == LanePreference {

    subscript(_ id: String) -> LanePreference? {
        get {
            self.first(where: { $0.id == id })
        }
        set {
            if let newValue = newValue,
               let index = self.firstIndex(where: { $0.id == id }) {
                self[index] = newValue
            }
        }
    }
}
