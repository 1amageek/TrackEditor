//
//  SwiftUIView.swift
//  
//
//  Created by nori on 2022/04/08.
//

import SwiftUI

public struct TrackLane<Data, Content, Header, SubTrackLane> {

    @Environment(\.laneRange) var laneRange: Range<Int>

    @Environment(\.trackEditorOptions) var options: TrackEditorOptions

    @State var isSubTracksExpanded: Bool = false

    var data: [Data]

    var content: (Data) -> Content

    var header: (ExpandAction) -> Header

    var subTrackLane: () -> SubTrackLane

    var isContentEmpty: Bool

    var trackEditorAreaWidth: CGFloat { options.barWidth * CGFloat(laneRange.count) }
}

extension TrackLane where Data: Hashable & LaneRegioning {
    var sortedData: [Data] {
        data.sorted(by: { $0.startRegion(options) < $1.startRegion(options) })
    }
}

extension TrackLane: View where Data: Hashable & LaneRegioning, Content: View, Header: View, SubTrackLane: View {

    public init(
        _ data: [Data],
        @ViewBuilder content: @escaping (Data) -> Content,
        @ViewBuilder header: @escaping (ExpandAction) -> Header,
        @ViewBuilder subTrackLane: @escaping () -> SubTrackLane
    ) {
        self.data = data
        self.content = content
        self.header = header
        self.subTrackLane = subTrackLane
        self.isContentEmpty = false
    }

    public var body: some View {
        VStack(spacing: 0) {
            if !isContentEmpty {
                trackLane()
                    .frame(width: trackEditorAreaWidth + options.headerWidth, height: options.trackHeight, alignment: .leading)
            }
            subTrackView()
        }
    }

    func regionPreference(data: [Data], region: Data) -> (width: CGFloat, padding: CGFloat) {
        let index = data.firstIndex(of: region)!
        let prevIndex = index - 1
        let prevEnd = prevIndex < 0 ? laneRange.lowerBound : sortedData[prevIndex].endRegion(options)
        let start = region.startRegion(options)
        let end = region.endRegion(options)
        let leadingPadding = CGFloat(start - prevEnd) * options.barWidth
        let width = CGFloat(end - start) * options.barWidth
        return (width: width, padding: leadingPadding)
    }

    @ViewBuilder
    func trackLane() -> some View {
        let expand: ExpandAction = ExpandAction {
            withAnimation {
                self.isSubTracksExpanded.toggle()
            }
        }
        let sortedData = sortedData
        LazyHStack(alignment: .top, spacing: 0, pinnedViews: .sectionHeaders) {
            Section {
                ForEach(sortedData, id: \.self) { region in
                    let (width, padding) = regionPreference(data: sortedData, region: region)
                    content(region)
                        .frame(width: width)
                        .padding(.leading, padding)
                        .id(region)
                }
            } header: {
                header(expand)
                    .frame(width: options.headerWidth, height: options.trackHeight)
            }
        }
    }

    @ViewBuilder
    func subTrackView() -> some View {
        if isSubTracksExpanded {
            subTrackLane()
        }
    }
}

extension TrackLane where Data: Hashable & LaneRegioning, Content: View, Header: View, SubTrackLane == EmptyView {

    public init(
        _ data: [Data],
        @ViewBuilder content: @escaping (Data) -> Content,
        @ViewBuilder header: @escaping (ExpandAction) -> Header
    ) {
        self.data = data
        self.content = content
        self.header = header
        self.subTrackLane = { EmptyView() }
        self.isContentEmpty = false
    }
}

extension TrackLane where Data: Hashable & LaneRegioning, Content == EmptyView, Header == EmptyView, SubTrackLane: View {

    public init(
        _ data: [Data],
        @ViewBuilder subTrackLane: @escaping () -> SubTrackLane
    ) {
        self.data = data
        self.content = { _ in EmptyView() }
        self.header = { _ in EmptyView() }
        self.subTrackLane = subTrackLane
        self._isSubTracksExpanded = State(initialValue: true)
        self.isContentEmpty = true
    }
}
