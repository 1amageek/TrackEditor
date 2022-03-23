//
//  TrackEditor.swift
//  
//
//  Created by nori on 2022/03/22.
//

import SwiftUI

public struct Track: Identifiable, Hashable {

    public var id: String

    public var label: String

    public var regions: [Region]

    public var subTracks: [Track]

    public init(
        id: String,
        label: String,
        regions: [Region],
        subTracks: [Track] = []
    ) {
        self.id = id
        self.label = label
        self.regions = regions
        self.subTracks = subTracks
    }
}

public struct Region: Hashable {

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

public struct TrackEditor<RulerHeader: View, Ruler: View, TrackHeader: View, Content: View>: View {

    var tracks: [Track] = []

    var content: (Track, Region) -> Content

    var rulerHeader: () -> RulerHeader

    var ruler: (Int) -> Ruler

    var trackHeader: (Track) -> TrackHeader

    var numberOfBars: Int

    @State var headerWidth: CGFloat = 200

    @State var rulerHeight: CGFloat = 44

    @State var trackHeight: CGFloat = 80

    @State var barWidth: CGFloat = 100

    public init(
        _ trasks: [Track],
        numberOfBars: Int,
        @ViewBuilder content: @escaping (Track, Region) -> Content,
        @ViewBuilder rulerHeader: @escaping () -> RulerHeader,
        @ViewBuilder ruler: @escaping (Int) -> Ruler,
        @ViewBuilder trackHeader: @escaping (Track) -> TrackHeader
    ) {
        self.tracks = trasks
        self.numberOfBars = numberOfBars
        self.rulerHeader = rulerHeader
        self.ruler = ruler
        self.trackHeader = trackHeader
        self.content = content
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
                    laneBackground(track: track)
                        .frame(width: trackEditorAreaSize.width + headerWidth, height: trackHeight, alignment: .leading)
                        .overlay {
                            laneView(track: track)
                                .frame(width: trackEditorAreaSize.width + headerWidth, height: trackHeight, alignment: .leading)
                        }
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

    @ViewBuilder
    func laneView(track: Track) -> some View {
        let regions = track.regions.sorted(by: { $0.end < $1.end })
        LazyHStack(alignment: .top, spacing: 0, pinnedViews: .sectionHeaders) {
            Section {
                ForEach(regions, id: \.self) { region in
                    let index = regions.firstIndex(of: region)!
                    let prevIndex = index - 1
                    let prevEnd = prevIndex < 0 ? 0 : regions[prevIndex].end
                    let leadingPadding = CGFloat(region.start - prevEnd) * barWidth
                    let width = CGFloat(region.end - region.start) * barWidth
                    content(track, region)
                        .frame(width: width)
                        .padding(.leading, leadingPadding)
                }
            } header: {
                trackHeader(track)
                    .frame(width: headerWidth, height: trackHeight)
            }
        }
    }

    @ViewBuilder
    func laneBackground(track: Track) -> some View {
        LazyHStack(spacing: 0, pinnedViews: .sectionHeaders) {
            Section {
                ForEach(0..<numberOfBars, id: \.self) { region in
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

struct TrackEditor_Previews: PreviewProvider {

    struct ContentView: View {

        var body: some View {
            TrackEditor([
                Track(id: "0", label: "Label0", regions: [
                    Region(label: "0", start: 0, end: 3),
                    Region(label: "2", start: 4, end: 6),
                    Region(label: "3", start: 7, end: 8),
                    Region(label: "4", start: 8, end: 10),
                    Region(label: "5", start: 12, end: 19)
                ]),
                Track(id: "1", label: "Label1", regions: [
                    Region(label: "0", start: 0, end: 4),
                    Region(label: "2", start: 4, end: 8),
                    Region(label: "4", start: 8, end: 10)
                ]),
                Track(id: "2", label: "Label2", regions: [
                    Region(label: "0", start: 2, end: 3),
                    Region(label: "2", start: 4, end: 6),
                    Region(label: "3", start: 7, end: 10),
                    Region(label: "5", start: 10, end: 15)
                ]),
            ], numberOfBars: 20) { track, region in
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
            } trackHeader: { track in
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(track.label)
                                .bold()
                            Toggle(isOn: .constant(true)) {
                                Text("On")
                            }
                            .toggleStyle(.button)
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
            }
        }
    }

    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
