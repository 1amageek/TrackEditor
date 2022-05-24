//
//  SwiftUIView.swift
//  
//
//  Created by nori on 2022/04/26.
//

import SwiftUI

public struct Arrange<Data, Content> {

    @Environment(\.laneRange) var laneRange: Range<Int>

    @Environment(\.trackOptions) var options: TrackOptions

    @Environment(\.selection) var selection: Binding<RegionSelection?>

    @Environment(\.trackNamespace) var namespace: Namespace

    @Environment(\.laneID) var laneID: String

    var data: [Data]

    var content: (Data) -> Content
}

extension Arrange: View where Data: Identifiable & LaneRegioning, Content: View {

    public init(_ data: [Data], @ViewBuilder content: @escaping (Data) -> Content) {
        self.data = data
        self.content = content
    }

    var sortedData: [Data] {
        data.sorted(by: { $0.startRegion(laneRange, options: options) < $1.startRegion(laneRange, options: options) })
    }

    public var body: some View {
        ForEach(sortedData, id: \.id) { element in
            let (width, padding) = position(data: sortedData, element: element)
            content(element)
                .frame(width: width)
                .anchorPreference(key: RegionPreferenceKey.self, value: .bounds, transform: { [RegionPreference(id: "\(element.id)", laneID: laneID, bounds: $0)] })
                .padding(.leading, padding)
        }
    }

    func position(data: [Data], element: Data) -> (width: CGFloat, padding: CGFloat) {
        let options = options
        let laneRange = laneRange
        let index = data.firstIndex(where: { $0.id == element.id })!
        let prevIndex = index - 1
        let min = CGFloat(laneRange.lowerBound)
        let prevEnd = prevIndex < 0 ? min : max(min, data[prevIndex].endRegion(laneRange, options: options))
        let start = element.startRegion(laneRange, options: options)
        let end = element.endRegion(laneRange, options: options)
        let leadingPadding = CGFloat(start - prevEnd) * options.barWidth
        let width = CGFloat(end - start) * options.barWidth
        return (width: width, padding: leadingPadding)
    }
}
