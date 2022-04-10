//
//  TrackEditor.swift
//  
//
//  Created by nori on 2022/03/22.
//

import SwiftUI

public protocol LaneRegioning {
    func startRegion(_ options: TrackEditorOptions) -> CGFloat
    func endRegion(_ options: TrackEditorOptions) -> CGFloat
}

public struct ExpandAction {

    var action: () -> Void

    init(_ action: @escaping () -> Void) {
        self.action = action
    }

    public func callAsFunction() {
        self.action()
    }
}

public enum Interval {
    case month(Int)
    case day(Int)
    case hour(Int)
    case minute(Int)
    case second(Int)
}

public struct TrackEditorOptions {
    public var interval: Interval
    public var reference: DateComponents
    public var headerWidth: CGFloat
    public var trackHeight: CGFloat
    public var barWidth: CGFloat
    public init(
        interval: Interval = .minute(15),
        reference: DateComponents = Calendar(identifier: .iso8601).dateComponents([.calendar, .timeZone, .year, .month, .day], from: Date()),
        headerWidth: CGFloat = 200,
        trackHeight: CGFloat = 80,
        barWidth: CGFloat = 100
    ) {
        self.interval = interval
        self.reference = reference
        self.headerWidth = headerWidth
        self.trackHeight = trackHeight
        self.barWidth = barWidth
    }
}

private struct TrackEditorLaneRangeKey: EnvironmentKey {
    static let defaultValue: Range<Int> = 0..<100
}

private struct TrackEditorOptionsKey: EnvironmentKey {
    static let defaultValue: TrackEditorOptions = TrackEditorOptions()
}

extension EnvironmentValues {

    var laneRange: Range<Int> {
        get { self[TrackEditorLaneRangeKey.self] }
        set { self[TrackEditorLaneRangeKey.self] = newValue }
    }

    var trackEditorOptions: TrackEditorOptions {
        get { self[TrackEditorOptionsKey.self] }
        set { self[TrackEditorOptionsKey.self] = newValue }
    }
}

public struct TrackEditor<Content, Header, Ruler> {

    var range: Range<Int>

    var options: TrackEditorOptions

    var content: () -> Content

    var header: () -> Header

    var ruler: (Int) -> Ruler

}

extension TrackEditor: View where Content: View, Header: View, Ruler: View {

    public init(
        _ range: Range<Int>,
        options: TrackEditorOptions = TrackEditorOptions(),
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder ruler: @escaping (Int) -> Ruler
    ) {
        self.range = range
        self.options = options
        self.content = content
        self.header = header
        self.ruler = ruler
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollView([.vertical, .horizontal], showsIndicators: true) {
                ZStack(alignment: .topLeading) {
                    LazyHStack(spacing: 0) {
                        Section {
                            ForEach(range, id: \.self) { index in
                                HStack {
                                    Divider()
                                    Spacer()
                                }
                                .frame(width: options.barWidth)
                            }
                        }
                    }
                    .padding(.leading, options.headerWidth)
                    contentView
                }
                .frame(minWidth: proxy.size.width, minHeight: proxy.size.height, alignment: .topLeading)
            }
            .clipped()
        }
    }

    @ViewBuilder
    private var contentView: some View {
        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
            Section {
                content()
                    .environment(\.laneRange, range)
                    .environment(\.trackEditorOptions, options)
            } header: {
                LazyHStack(spacing: 0, pinnedViews: .sectionHeaders) {
                    Section {
                        ForEach(range, id: \.self) { index in
                            ruler(index)
                                .frame(width: options.barWidth)
                        }
                    } header: {
                        header()
                            .frame(width: options.headerWidth)
                    }
                }
            }
        }
    }
}

extension TrackEditor where Content: View, Header == EmptyView, Ruler == EmptyView {

    public init(
        _ range: Range<Int>,
        options: TrackEditorOptions = TrackEditorOptions(),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.range = range
        self.options = options
        self.content = content
        self.header = { EmptyView() }
        self.ruler = { _ in EmptyView() }
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollView([.vertical, .horizontal], showsIndicators: true) {
                headerlessContentView
                    .frame(minWidth: proxy.size.width, minHeight: proxy.size.height, alignment: .topLeading)
            }
            .clipped()
        }
    }

    @ViewBuilder
    private var headerlessContentView: some View {
        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
            Section {
                content()
                    .environment(\.laneRange, range)
                    .environment(\.trackEditorOptions, options)
            }
        }
    }
}


struct TrackEditor_Previews: PreviewProvider {

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

        func startRegion(_ options: TrackEditorOptions) -> CGFloat {
            CGFloat(start)
        }

        func endRegion(_ options: TrackEditorOptions) -> CGFloat {
            CGFloat(end)
        }
    }

    public struct Cell: Hashable, LaneRegioning {

        public var index: Int

        func startRegion(_ options: TrackEditorOptions) -> CGFloat {
            CGFloat(index)
        }

        func endRegion(_ options: TrackEditorOptions) -> CGFloat {
            CGFloat(index + 1)
        }
    }

    static let data = [
        Track(id: "0", label: "Label0", regions: [
            Region(label: "0", start: 0, end: 2.5),
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
                                subTrack(track: track)
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

        func subTrack(track: Track) -> some View{
            ForEach(track.subTracks) { track in
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
                    ForEach((track.subTracks)) { track in

                        let cells = (3..<13).map({ index in
                            Cell(index: index)
                        })

                        TrackLane(cells) { region in
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
                            EmptyView()
                        }
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
