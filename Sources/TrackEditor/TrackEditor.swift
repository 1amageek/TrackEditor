//
//  TrackEditor.swift
//  
//
//  Created by nori on 2022/03/22.
//

import SwiftUI

public protocol TrackRegioning {
    var start: Int { get }
    var end: Int { get }
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

public struct TrackEditor<
    Tracks: RandomAccessCollection,
    SubTracks: RandomAccessCollection,
    Region: Hashable & TrackRegioning,
    RulerHeader: View,
    Ruler: View,
    TrackHeader: View,
    SubTrackHeader: View,
    Content: View
>: View where Tracks.Element: Identifiable, SubTracks.Element: Identifiable {

    @Environment(\.dismiss) var dismiss

    public typealias Track = Tracks.Element

    public typealias SubTrack = SubTracks.Element

    var tracks: Tracks

    var numberOfBars: Int

    var subTracksForTrack: (Track) -> SubTracks

    var regionsForTrack: (Track) -> Array<Region>

    var regionsForSubTrack: (SubTrack) -> Array<Region>

    var content: (Region) -> Content

    var rulerHeader: () -> RulerHeader

    var ruler: (Int) -> Ruler

    var trackHeader: (Track, ExpandAction) -> TrackHeader

    var subTrackHeader: (SubTrack) -> SubTrackHeader

    @State var headerWidth: CGFloat = 200

    @State var rulerHeight: CGFloat = 44

    @State var trackHeight: CGFloat = 80

    @State var barWidth: CGFloat = 100

    public init(
        _ trasks: Tracks,
        numberOfBars: Int,
        @ViewBuilder content: @escaping (Region) -> Content,
        @ViewBuilder rulerHeader: @escaping () -> RulerHeader,
        @ViewBuilder ruler: @escaping (Int) -> Ruler,
        @ViewBuilder trackHeader: @escaping (Track, ExpandAction) -> TrackHeader,
        @ViewBuilder subTrackHeader: @escaping (SubTrack) -> SubTrackHeader,
        subTracksForTrack: @escaping (Track) -> SubTracks,
        regionsForTrack: @escaping (Track) -> Array<Region>,
        regionsForSubTrack:  @escaping (SubTrack) -> Array<Region>
    ) {
        self.tracks = trasks
        self.content = content
        self.numberOfBars = numberOfBars
        self.rulerHeader = rulerHeader
        self.ruler = ruler
        self.trackHeader = trackHeader
        self.subTrackHeader = subTrackHeader
        self.subTracksForTrack = subTracksForTrack
        self.regionsForTrack = regionsForTrack
        self.regionsForSubTrack = regionsForSubTrack
    }

    var trackEditorAreaSize: CGSize {
        let width: CGFloat = barWidth * CGFloat(numberOfBars)
        let heigth: CGFloat = trackHeight * CGFloat(tracks.count)
        return CGSize(width: width, height: heigth)
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollViewReader { _ in
                ScrollView([.vertical, .horizontal], showsIndicators: true) {
                    contentView
                        .frame(width: trackEditorAreaSize.width + headerWidth, height: proxy.size.height, alignment: .top)
                        .background(Color(.systemBackground))
                }
                .clipped()
            }
        }
    }

    @ViewBuilder
    var contentView: some View {
        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
            Section {
                ForEach(tracks, id: \.id) { track in
                    TrackView(track,
                              numberOfBars: numberOfBars,
                              trackEditorAreaSize: trackEditorAreaSize,
                              content: content,
                              rulerHeader: rulerHeader,
                              ruler: ruler,
                              trackHeader: trackHeader,
                              subTrackHeader: subTrackHeader,
                              subTracksForTrack: subTracksForTrack,
                              regionsForTrack: regionsForTrack,
                              regionsForSubTrack: regionsForSubTrack)
                }
            } header: {
                LazyHStack(spacing: 0, pinnedViews: .sectionHeaders) {
                    Section {
                        ForEach(0..<numberOfBars, id: \.self) { index in
                            ruler(index)
                                .frame(width: barWidth)
                        }
                    } header: {
                        rulerHeader()
                            .frame(width: headerWidth)
                    }
                }
                .frame(width: trackEditorAreaSize.width + headerWidth, height: rulerHeight, alignment: .leading)
            }
        }
    }
}

extension TrackEditor {

    struct TrackView: View {

        typealias Track = Tracks.Element

        typealias SubTrack = SubTracks.Element

        @State var isSubTracksExpandActioned: Bool = false

        var track: Track

        var numberOfBars: Int

        var subTracksForTrack: (Track) -> SubTracks

        var regionsForTrack: (Track) -> Array<Region>

        var regionsForSubTrack: (SubTrack) -> Array<Region>

        var content: (Region) -> Content

        var rulerHeader: () -> RulerHeader

        var ruler: (Int) -> Ruler

        var trackHeader: (Track, ExpandAction) -> TrackHeader

        var subTrackHeader: (SubTrack) -> SubTrackHeader

        var headerWidth: CGFloat = 200

        var rulerHeight: CGFloat = 44

        var trackHeight: CGFloat = 80

        var barWidth: CGFloat = 100

        var trackEditorAreaSize: CGSize

        public init(
            _ trask: Track,
            numberOfBars: Int,
            trackEditorAreaSize: CGSize,
            @ViewBuilder content: @escaping (Region) -> Content,
            @ViewBuilder rulerHeader: @escaping () -> RulerHeader,
            @ViewBuilder ruler: @escaping (Int) -> Ruler,
            @ViewBuilder trackHeader: @escaping (Track, ExpandAction) -> TrackHeader,
            @ViewBuilder subTrackHeader: @escaping (SubTrack) -> SubTrackHeader,
            subTracksForTrack: @escaping (Track) -> SubTracks,
            regionsForTrack: @escaping (Track) -> Array<Region>,
            regionsForSubTrack:  @escaping (SubTrack) -> Array<Region>
        ) {
            self.track = trask
            self.content = content
            self.numberOfBars = numberOfBars
            self.trackEditorAreaSize = trackEditorAreaSize
            self.rulerHeader = rulerHeader
            self.ruler = ruler
            self.trackHeader = trackHeader
            self.subTrackHeader = subTrackHeader
            self.subTracksForTrack = subTracksForTrack
            self.regionsForTrack = regionsForTrack
            self.regionsForSubTrack = regionsForSubTrack
        }

        var body: some View {
            VStack(spacing: 0) {
                laneBackground()
                    .frame(width: trackEditorAreaSize.width + headerWidth, height: trackHeight, alignment: .leading)
                    .overlay {
                        trackLaneView(track: track)
                            .frame(width: trackEditorAreaSize.width + headerWidth, height: trackHeight, alignment: .leading)
                    }
                subTrackView(track: track)
            }
        }

        @ViewBuilder
        func subTrackView(track: Track) -> some View {
            if isSubTracksExpandActioned {
                let subTracks = subTracksForTrack(track)
                if !subTracks.isEmpty {
                    ForEach(subTracks, id: \.id) { subTrack in
                        laneBackground()
                            .frame(width: trackEditorAreaSize.width + headerWidth, height: trackHeight, alignment: .leading)
                            .overlay {
                                subTrackLaneView(subTrack: subTrack)
                                    .frame(width: trackEditorAreaSize.width + headerWidth, height: trackHeight, alignment: .leading)
                            }
                    }
                }
            }
        }

        @ViewBuilder
        func trackLaneView(track: Track) -> some View {
            let regions = regionsForTrack(track)
            let expand: ExpandAction = ExpandAction {
                withAnimation {
                    self.isSubTracksExpandActioned.toggle()
                }
            }
            LazyHStack(alignment: .top, spacing: 0, pinnedViews: .sectionHeaders) {
                Section {
                    ForEach(regions, id: \.self) { region in
                        let index = regions.firstIndex(of: region)!
                        let prevIndex = index - 1
                        let prevEnd = prevIndex < 0 ? 0 : regions[prevIndex].end
                        let leadingPadding = CGFloat(region.start - prevEnd) * barWidth
                        let width = CGFloat(region.end - region.start) * barWidth
                        content(region)
                            .frame(width: width)
                            .padding(.leading, leadingPadding)
                    }
                } header: {
                    trackHeader(track, expand)
                        .frame(width: headerWidth, height: trackHeight)
                }
            }
        }

        @ViewBuilder
        func subTrackLaneView(subTrack: SubTrack) -> some View {
            let regions = regionsForSubTrack(subTrack)
            LazyHStack(alignment: .top, spacing: 0, pinnedViews: .sectionHeaders) {
                Section {
                    ForEach(regions, id: \.self) { region in
                        let index = regions.firstIndex(of: region)!
                        let prevIndex = index - 1
                        let prevEnd = prevIndex < 0 ? 0 : regions[prevIndex].end
                        let leadingPadding = CGFloat(region.start - prevEnd) * barWidth
                        let width = CGFloat(region.end - region.start) * barWidth
                        content(region)
                            .frame(width: width)
                            .padding(.leading, leadingPadding)
                    }
                } header: {
                    subTrackHeader(subTrack)
                        .frame(width: headerWidth, height: trackHeight)
                }
            }
        }

        @ViewBuilder
        func laneBackground() -> some View {
            LazyHStack(spacing: 0, pinnedViews: .sectionHeaders) {
                Section {
                    ForEach(0..<numberOfBars, id: \.self) { _ in
                        Color(.systemGray4)
                            .padding(0.5)
                            .frame(width: barWidth)
                    }
                } header: {
                    Spacer()
                        .frame(width: headerWidth, height: trackHeight)
                }
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

    public struct Region: Hashable, TrackRegioning {

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
    }

    struct ContentView: View {

        var body: some View {
            TrackEditor([
                Track(id: "0", label: "Label0", regions: [
                    Region(label: "0", start: 0, end: 3),
                    Region(label: "2", start: 4, end: 6),
                    Region(label: "3", start: 7, end: 8),
                    Region(label: "4", start: 8, end: 10),
                    Region(label: "5", start: 12, end: 19)
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
            ], numberOfBars: 20) { region in
                RoundedRectangle(cornerRadius: 12)
                    .fill(.blue.opacity(0.7))
                    .padding(1)
            } rulerHeader: {
                Color(.systemGray6)
            } ruler: { index in
                HStack {
                    Spacer()
                    Text("\(index)")
                    Divider()
                }
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
            } trackHeader: { track, expand in
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
                .background(Color(.systemGray5))
            } subTrackHeader: { subTrack in
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(subTrack.label)
                                .bold()
                        }
                        .padding(.leading, 16)
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 8)
                    Spacer()
                    Divider()
                }
                .frame(maxHeight: .infinity)
                .background(Color(.systemGray5))
            } subTracksForTrack: { track -> [Track] in
                return track.subTracks
            } regionsForTrack: { track in
                return track.regions.sorted(by: { $0.end < $1.end })
            } regionsForSubTrack: { subTrack in
                return subTrack.regions.sorted(by: { $0.end < $1.end })
            }
        }
    }

    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
