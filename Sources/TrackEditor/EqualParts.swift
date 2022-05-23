//
//  SwiftUIView.swift
//  
//
//  Created by nori on 2022/04/26.
//

import SwiftUI

public struct EqualParts<Content> {

    @Environment(\.laneRange) var laneRange: Range<Int>

    @Environment(\.trackOptions) var options: TrackOptions

    var number: Int

    var content: (Int) -> Content
}

extension EqualParts: View where Content: View {

    public init(_ number: Int, @ViewBuilder content: @escaping (Int) -> Content) {
        self.number = number
        self.content = content
    }

    var width: CGFloat {
        CGFloat(laneRange.upperBound - laneRange.lowerBound) * options.barWidth / CGFloat(number)
    }

    public var body: some View {
        ForEach(0..<number, id: \.self) { index in
            content(index)
                .frame(width: width)
        }
    }
}
