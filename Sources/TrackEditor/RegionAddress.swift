//
//  RegionAddress.swift
//  
//
//  Created by nori on 2022/04/19.
//

import Foundation

public struct RegionAddress: Identifiable, Hashable {
    public var id: AnyHashable
    public var range: Range<Int>
    public init<V>(id: V, range: Range<Int>) where V: Hashable {
        self.id = AnyHashable(id)
        self.range = range
    }
}
