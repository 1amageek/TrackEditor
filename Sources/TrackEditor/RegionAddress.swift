//
//  RegionAddress.swift
//  
//
//  Created by nori on 2022/04/19.
//

import Foundation

public struct RegionAddress: Identifiable, Hashable {
    public var id: AnyHashable
    public var index: Int
    public init<V>(id: V, index: Int) where V: Hashable {
        self.id = AnyHashable(id)
        self.index = index
    }
}
