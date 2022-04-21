//
//  RegionAddress.swift
//  
//
//  Created by nori on 2022/04/19.
//

import Foundation

public struct RegionAddress: Identifiable, Hashable {
    public var id: String
    public var range: Range<Int>

    public init(id: String, range: Range<Int>) {
        self.id = id
        self.range = range
    }
}
