//
//  TrackLane.swift
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

    var trackEditorAreaWidth: CGFloat { options.barWidth * CGFloat(laneRange.count) }
}

extension TrackLane where Data: Hashable & LaneRegioning {
    var sortedData: [Data] {
        data.sorted(by: { $0.startRegion(laneRange, options: options) < $1.startRegion(laneRange, options: options) })
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
    }

    public var body: some View {
        VStack(spacing: 0) {
            trackLane()
                .frame(width: trackEditorAreaWidth + options.headerWidth, height: options.trackHeight, alignment: .leading)
            subTrackView()
        }
    }

    func regionPreference(data: [Data], region: Data) -> (width: CGFloat, padding: CGFloat) {
        let index = data.firstIndex(of: region)!
        let prevIndex = index - 1
        let prevEnd = prevIndex < 0 ? CGFloat(laneRange.lowerBound) : sortedData[prevIndex].endRegion(laneRange, options:options)
        let start = region.startRegion(laneRange, options:options)
        let end = region.endRegion(laneRange, options:options)
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
    }
}

struct TrackLane_Previews: PreviewProvider {

    public struct Track: Identifiable, Hashable {

        public var id: String

        public var parentID: String?

        public var label: String

        public var regions: [Region]

        public var subTracks: [Track]

        public var isSubTracksExpandActioned: Bool

        public init(
            id: String,
            parentID: String? = nil,
            label: String,
            regions: [Region],
            subTracks: [Track] = [],
            isSubTracksExpandActioned: Bool = false
        ) {
            self.id = id
            self.parentID = parentID
            self.label = label
            self.regions = regions
            self.subTracks = subTracks
            self.isSubTracksExpandActioned = isSubTracksExpandActioned
        }
    }

    public struct Region: Hashable, LaneRegioning {

        public var label: String
        public var start: CGFloat
        public var end: CGFloat

        public init(
            label: String,
            start: CGFloat,
            end: CGFloat
        ) {
            self.label = label
            self.start = start
            self.end = end
        }

        func startRegion(_ range: Range<Int>, options: TrackEditorOptions) -> CGFloat {
            CGFloat(start)
        }

        func endRegion(_ range: Range<Int>, options: TrackEditorOptions) -> CGFloat {
            CGFloat(end)
        }
    }

    public struct Cell: Hashable, LaneRegioning {

        public var index: Int

        func startRegion(_ range: Range<Int>, options: TrackEditorOptions) -> CGFloat {
            CGFloat(index)
        }

        func endRegion(_ range: Range<Int>, options: TrackEditorOptions) -> CGFloat {
            CGFloat(index + 1)
        }
    }

    static let data = [
        Track(id: "0", label: "Label0", regions: [
            Region(label: "0", start: 0, end: 3),
            Region(label: "2", start: 4, end: 6),
            Region(label: "3", start: 7, end: 8),
            Region(label: "4", start: 8, end: 10),
            Region(label: "5", start: 86, end: 100)
        ], subTracks: [
            Track(id: "1", parentID: "0", label: "SubTack label 0", regions: [
                Region(label: "0", start: 0, end: 4),
                Region(label: "2", start: 4, end: 8),
                Region(label: "4", start: 8, end: 10)
            ], subTracks: [
                Track(id: "1", parentID: "0", label: "Sub SubTack label 0", regions: [
                    Region(label: "0", start: 0, end: 4),
                    Region(label: "2", start: 4, end: 8),
                    Region(label: "4", start: 8, end: 10)
                ]),
                Track(id: "3", parentID: "0", label: "Sub SubTack label 0", regions: [
                    Region(label: "0", start: 0, end: 4),
                    Region(label: "2", start: 4, end: 8),
                    Region(label: "4", start: 8, end: 10)
                ]),
                Track(id: "4", parentID: "0", label: "Sub SubTack label 0", regions: [
                    Region(label: "0", start: 0, end: 4),
                    Region(label: "2", start: 4, end: 8),
                    Region(label: "4", start: 8, end: 10)
                ])
            ]),
            Track(id: "3", parentID: "0", label: "SubTack label 0", regions: [
                Region(label: "0", start: 0, end: 4),
                Region(label: "2", start: 4, end: 8),
                Region(label: "4", start: 8, end: 10)
            ]),
            Track(id: "4", parentID: "0", label: "SubTack label 0", regions: [
                Region(label: "0", start: 0, end: 4),
                Region(label: "2", start: 4, end: 8),
                Region(label: "4", start: 8, end: 10)
            ])
        ]),
        Track(id: "1", label: "Label1", regions: [
            Region(label: "0", start: 0, end: 4),
            Region(label: "2", start: 4, end: 8),
            Region(label: "4", start: 8, end: 10)
        ], subTracks: [
            Track(id: "1", parentID: "0", label: "SubTack label 0", regions: [
                Region(label: "0", start: 0, end: 4),
                Region(label: "2", start: 4, end: 8),
                Region(label: "4", start: 8, end: 10)
            ]),
            Track(id: "3", parentID: "0", label: "SubTack label 0", regions: [
                Region(label: "0", start: 0, end: 4),
                Region(label: "2", start: 4, end: 8),
                Region(label: "4", start: 8, end: 10)
            ]),
            Track(id: "4", parentID: "0", label: "SubTack label 0", regions: [
                Region(label: "0", start: 0, end: 4),
                Region(label: "2", start: 4, end: 8),
                Region(label: "4", start: 8, end: 10)
            ])
        ]),
        Track(id: "2", label: "Label2", regions: [
            Region(label: "0", start: 2, end: 3),
            Region(label: "2", start: 4, end: 6),
            Region(label: "3", start: 7, end: 10),
            Region(label: "5", start: 10, end: 15)
        ], subTracks: [
            Track(id: "1", parentID: "0", label: "SubTack label 0", regions: [
                Region(label: "0", start: 0, end: 4),
                Region(label: "2", start: 4, end: 8),
                Region(label: "4", start: 8, end: 10)
            ]),
            Track(id: "3", parentID: "0", label: "SubTack label 0", regions: [
                Region(label: "0", start: 0, end: 4),
                Region(label: "2", start: 4, end: 8),
                Region(label: "4", start: 8, end: 10)
            ]),
            Track(id: "4", parentID: "0", label: "SubTack label 0", regions: [
                Region(label: "0", start: 0, end: 4),
                Region(label: "2", start: 4, end: 8),
                Region(label: "4", start: 8, end: 10)
            ])
        ]),
    ]

    struct ContentView: View {
        var body: some View {
            TrackEditor(1..<30) {
                VStack {
                    ForEach(data, id: \.id) { track in
                        TrackLane(track.regions) { region in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.green.opacity(0.7))
                                .padding(1)
                        } header: { expand in
                            VStack {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(track.label)
                                            .bold()
                                        Button("ExpandAction") {
                                            expand()
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 14)
                                .padding(.top, 8)
                                Spacer()
                                Divider()
                            }
                            .frame(maxHeight: .infinity)
                            .background(Color.white)
                        }
                    }
                    ForEach(data, id: \.id) { track in
                        TrackLane(track.regions) { region in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.green.opacity(0.7))
                                .padding(1)
                        } header: { expand in
                            VStack {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(track.label)
                                            .bold()
                                        Button("ExpandAction") {
                                            expand()
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 14)
                                .padding(.top, 8)
                                Spacer()
                                Divider()
                            }
                            .frame(maxHeight: .infinity)
                            .background(Color.white)
                        } subTrackLane: {
                            ForEach(data, id: \.id) { track in
                                TrackLane(track.regions) { region in
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.blue.opacity(0.7))
                                        .padding(1)
                                } header: { expand in
                                    VStack {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(track.label)
                                                    .bold()
                                                Button("ExpandAction") {
                                                    expand()
                                                }
                                            }
                                            Spacer()
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.top, 8)
                                        Spacer()
                                        Divider()
                                    }
                                    .frame(maxHeight: .infinity)
                                    .background(Color.white)
                                }
                            }
                        }
                    }
                }
            } header: {
                Color.white
                    .frame(height: 44)
            } ruler: { index in
                HStack {
                    Text("\(index)")
                        .padding(.horizontal, 12)
                    Spacer()
                    Divider()
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .tag(index)
            }
        }
    }

    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
