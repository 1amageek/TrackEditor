//
//  TrackGrid.swift
//  
//
//  Created by nori on 2022/04/08.
//

import SwiftUI

public struct TrackGrid<Content, Header, SubTrackGrid> {

    @Environment(\.laneRange) var laneRange: Range<Int>

    @Environment(\.trackEditorOptions) var options: TrackEditorOptions

    @State var isSubTracksExpanded: Bool = false

    var content: (Int) -> Content

    var header: (ExpandAction) -> Header

    var subTrackGrid: () -> SubTrackGrid

    var isContentEmpty: Bool

    var trackEditorAreaWidth: CGFloat { options.barWidth * CGFloat(laneRange.count) }
}

extension TrackGrid: View where Content: View, Header: View, SubTrackGrid: View {

    public init(
        @ViewBuilder content: @escaping (Int) -> Content,
        @ViewBuilder header: @escaping (ExpandAction) -> Header,
        @ViewBuilder subTrackGrid: @escaping () -> SubTrackGrid
    ) {
        self.content = content
        self.header = header
        self.subTrackGrid = subTrackGrid
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

    @ViewBuilder
    func trackLane() -> some View {
        let expand: ExpandAction = ExpandAction {
            withAnimation {
                self.isSubTracksExpanded.toggle()
            }
        }
        LazyHStack(alignment: .top, spacing: 0, pinnedViews: .sectionHeaders) {
            Section {
                ForEach(laneRange, id: \.self) { index in
                    content(index)
                        .frame(width: options.barWidth)
                        .id(index)
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
            subTrackGrid()
        }
    }
}

extension TrackGrid where Content: View, Header: View, SubTrackGrid == EmptyView {

    public init(
        @ViewBuilder content: @escaping (Int) -> Content,
        @ViewBuilder header: @escaping (ExpandAction) -> Header
    ) {
        self.content = content
        self.header = header
        self.subTrackGrid = { EmptyView() }
        self.isContentEmpty = false
    }
}

extension TrackGrid where Content == EmptyView, Header == EmptyView, SubTrackGrid: View {

    public init(
        @ViewBuilder subTrackGrid: @escaping () -> SubTrackGrid
    ) {
        self.content = { _ in EmptyView() }
        self.header = { _ in EmptyView() }
        self.subTrackGrid = subTrackGrid
        self._isSubTracksExpanded = State(initialValue: true)
        self.isContentEmpty = true
    }
}


struct TrackGrid_Previews: PreviewProvider {

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
        public var start: Int
        public var end: Int

        public init(
            label: String,
            start: Int,
            end: Int
        ) {
            self.label = label
            self.start = start
            self.end = end
        }

        func startRegion(_ options: TrackEditorOptions) -> Int {
            start
        }

        func endRegion(_ options: TrackEditorOptions) -> Int {
            end
        }
    }

    public struct Cell: Hashable, LaneRegioning {

        public var index: Int

        func startRegion(_ options: TrackEditorOptions) -> Int {
            index
        }

        func endRegion(_ options: TrackEditorOptions) -> Int {
            index + 1
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
            ScrollViewReader { proxy in
                VStack {
                    Button("Scroll") {
                        withAnimation {
                            proxy.scrollTo(20)
                        }
                    }
                    TrackEditor(1..<30) {
                        ForEach(data, id: \.id) { track in
                            TrackGrid { _ in
                                Color.green
                                    .padding(1)
                            } header: { expand in
                                Button("Expand") {
                                    expand()
                                }
                            } subTrackGrid: {
                                TrackGrid { _ in
                                    Color.yellow
                                        .padding(1)
                                } header: { _ in
                                    Text("header")
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
        }
    }

    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
