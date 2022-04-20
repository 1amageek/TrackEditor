//
//  TrackEditor.swift
//  
//
//  Created by nori on 2022/03/22.
//

import SwiftUI

public struct ExpandAction {

    var action: () -> Void

    init(_ action: @escaping () -> Void) {
        self.action = action
    }

    public func callAsFunction() {
        self.action()
    }
}

public struct RegionMoveAction {

    var action: (RegionAddress) -> Void

    init(_ action: @escaping (RegionAddress) -> Void) {
        self.action = action
    }

    public func callAsFunction(address: RegionAddress) {
        self.action(address)
    }
}

public enum Interval {
    case month(Int)
    case day(Int)
    case hour(Int)
    case minute(Int)
    case second(Int)
}

public struct TrackOptions {
    public var interval: Interval
    public var reference: DateComponents
    public var headerWidth: CGFloat
    public var rulerHeight: CGFloat
    public var trackHeight: CGFloat
    public var barWidth: CGFloat
    public init(
        interval: Interval = .minute(15),
        reference: DateComponents = Calendar(identifier: .iso8601).dateComponents([.calendar, .timeZone, .year, .month, .day], from: Date()),
        headerWidth: CGFloat = 230,
        rulerHeight: CGFloat = 44,
        trackHeight: CGFloat = 80,
        barWidth: CGFloat = 100
    ) {
        self.interval = interval
        self.reference = reference
        self.headerWidth = headerWidth
        self.rulerHeight = rulerHeight
        self.trackHeight = trackHeight
        self.barWidth = barWidth
    }
}

private struct LaneRangeKey: EnvironmentKey {
    static let defaultValue: Range<Int> = 0..<100
}

private struct TrackOptionsKey: EnvironmentKey {
    static let defaultValue: TrackOptions = TrackOptions()
}

private struct TrackNamespaceKey: EnvironmentKey {
    static let defaultValue: Namespace = .init()
}

private struct TrackEditorEditingKey: EnvironmentKey {
    static let defaultValue: Binding<RegionSelection?> = .constant(nil)
}

private struct RegionDragGestureChangedKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

private struct RegionDragGestureEndedKey: EnvironmentKey {
    static let defaultValue: ((RegionAddress, RegionMoveAction) -> Void)? = nil
}

extension EnvironmentValues {

    var laneRange: Range<Int> {
        get { self[LaneRangeKey.self] }
        set { self[LaneRangeKey.self] = newValue }
    }

    var trackOptions: TrackOptions {
        get { self[TrackOptionsKey.self] }
        set { self[TrackOptionsKey.self] = newValue }
    }

    var trackNamespace: Namespace {
        get { self[TrackNamespaceKey.self] }
        set { self[TrackNamespaceKey.self] = newValue }
    }

    var selection: Binding<RegionSelection?> {
        get { self[TrackEditorEditingKey.self] }
        set { self[TrackEditorEditingKey.self] = newValue }
    }

    var onRegionDragGestureChanged: (() -> Void)? {
        get { self[RegionDragGestureChangedKey.self] }
        set { self[RegionDragGestureChangedKey.self] = newValue }
    }

    var onRegionDragGestureEnded: ((RegionAddress, RegionMoveAction) -> Void)? {
        get { self[RegionDragGestureEndedKey.self] }
        set { self[RegionDragGestureEndedKey.self] = newValue }
    }
}

public struct TrackEditor<Content, Header, Ruler, Placeholder> {

    @Namespace var namespace: Namespace.ID

    @Binding var selection: RegionSelection?

    var laneRange: Range<Int>

    var options: TrackOptions

    var content: () -> Content

    var header: () -> Header

    var ruler: (Int) -> Ruler

    var placeholder: (RegionSelection) -> Placeholder

    var onRegionDragGestureChanged: (() -> Void)?

    var onRegionDragGestureEnded: ((RegionAddress, RegionMoveAction) -> Void)?
}

extension TrackEditor: View where Content: View, Header: View, Ruler: View, Placeholder: View {

    init(
        _ laneRange: Range<Int>,
        selection: Binding<RegionSelection?>,
        options: TrackOptions = TrackOptions(),
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder ruler: @escaping (Int) -> Ruler,
        @ViewBuilder placeholder: @escaping (RegionSelection) -> Placeholder,
        onChanged: (() -> Void)?,
        onEnded: @escaping (RegionAddress, RegionMoveAction) -> Void
    ) {
        self.laneRange = laneRange
        self._selection = selection
        self.options = options
        self.content = content
        self.header = header
        self.ruler = ruler
        self.placeholder = placeholder
        self.onRegionDragGestureChanged = onChanged
        self.onRegionDragGestureEnded = onEnded
    }

    public init(
        _ laneRange: Range<Int>,
        selection: Binding<RegionSelection?>,
        options: TrackOptions = TrackOptions(),
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder ruler: @escaping (Int) -> Ruler,
        @ViewBuilder placeholder: @escaping (RegionSelection) -> Placeholder
    ) {
        self.laneRange = laneRange
        self._selection = selection
        self.options = options
        self.content = content
        self.header = header
        self.ruler = ruler
        self.placeholder = placeholder
    }

    public init(
        _ laneRange: Range<Int>,
        options: TrackOptions = TrackOptions(),
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder ruler: @escaping (Int) -> Ruler,
        @ViewBuilder placeholder: @escaping (RegionSelection) -> Placeholder
    ) {
        self.laneRange = laneRange
        self._selection = .constant(nil)
        self.options = options
        self.content = content
        self.header = header
        self.ruler = ruler
        self.placeholder = placeholder
    }

    public func onTrackGesture(_ onChanged: @escaping () -> Void, onEnded: @escaping (RegionAddress, RegionMoveAction) -> Void) -> Self {
        TrackEditor(laneRange, selection: $selection, options: options, content: content, header: header, ruler: ruler, placeholder: placeholder, onChanged: onChanged, onEnded: onEnded)
    }

    public func onTrackGestureEnded(onEnded: @escaping (RegionAddress, RegionMoveAction) -> Void) -> Self {
        TrackEditor(laneRange, selection: $selection, options: options, content: content, header: header, ruler: ruler, placeholder: placeholder, onChanged: nil, onEnded: onEnded)
    }

    var contentSize: CGSize {
        let width: CGFloat = options.barWidth * CGFloat(laneRange.upperBound - laneRange.lowerBound) + options.headerWidth
        let height: CGFloat = options.trackHeight
        return CGSize(width: width, height: height)
    }

    @ViewBuilder
    func editingRegion(_ value: [LanePreference]) -> some View {
        if let selection = selection {
            Region(animation: selection.id == nil) {
                placeholder(selection)
            }
            .frame(width: selection.changes.after.size.width, height: selection.changes.after.size.height)
            .offset(selection.changes.after.offset)
            .overlay(RegionDragGestureOverlay(regionID: selection.id, laneID: selection.laneID, preferenceValue: value))
            .overlay(RegionEdgeDragGestureOverlay(regionID: selection.id, laneID: selection.laneID, preferenceValue: value))
            .position(x: selection.changes.after.position.x, y: selection.changes.after.position.y) // Position is decided last
        }
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollView([.vertical, .horizontal], showsIndicators: true) {
                ZStack(alignment: .topLeading) {
                    LazyHStack(spacing: 0) {
                        Section {
                            ForEach(laneRange, id: \.self) { index in
                                HStack(spacing: 0) {
                                    Divider()
                                    Spacer()
                                }
                                .frame(width: options.barWidth)
                            }
                        }
                    }
                    .padding(.leading, options.headerWidth)
                    contentView
                        .frame(width: contentSize.width)
                        .overlayPreferenceValue(LanePreferenceKey.self) { value in
                            editingRegion(value)
                        }
                        .coordinateSpace(name: namespace)
                }
                .frame(minWidth: proxy.size.width, minHeight: proxy.size.height, alignment: .topLeading)
                .environment(\.trackNamespace, _namespace)
                .environment(\.laneRange, laneRange)
                .environment(\.trackOptions, options)
                .environment(\.selection, $selection)
                .environment(\.onRegionDragGestureChanged, onRegionDragGestureChanged)
                .environment(\.onRegionDragGestureEnded, onRegionDragGestureEnded)
            }
            .clipped()
        }
    }

    @ViewBuilder
    private var contentView: some View {
        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
            Section {
                content()
            } header: {
                LazyHStack(spacing: 0, pinnedViews: .sectionHeaders) {
                    Section {
                        ForEach(laneRange, id: \.self) { index in
                            ruler(index)
                                .frame(width: options.barWidth)
                        }
                    } header: {
                        header()
                            .frame(width: options.headerWidth)
                    }
                }
                .frame(height: options.rulerHeight)
            }
        }
    }
}

extension TrackEditor where Content: View, Header: View, Ruler: View, Placeholder == EmptyView {

    public init(
        _ laneRange: Range<Int>,
        options: TrackOptions = TrackOptions(),
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder ruler: @escaping (Int) -> Ruler
    ) {
        self.laneRange = laneRange
        self._selection = .constant(nil)
        self.options = options
        self.content = content
        self.header = header
        self.ruler = ruler
        self.placeholder = { _ in EmptyView() }
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollView([.vertical, .horizontal], showsIndicators: true) {
                ZStack(alignment: .topLeading) {
                    LazyHStack(spacing: 0) {
                        Section {
                            ForEach(laneRange, id: \.self) { index in
                                HStack(spacing: 0) {
                                    Divider()
                                    Spacer()
                                }
                                .frame(width: options.barWidth)
                            }
                        }
                    }
                    .contentShape(Rectangle())
                    .padding(.leading, options.headerWidth)

                    contentView
                        .frame(width: contentSize.width)
                        .coordinateSpace(name: namespace)
                }
                .frame(minWidth: proxy.size.width, minHeight: proxy.size.height, alignment: .topLeading)
            }
            .clipped()
        }
    }
}

extension TrackEditor where Content: View, Header == EmptyView, Ruler == EmptyView, Placeholder == EmptyView {

    public init(
        _ laneRange: Range<Int>,
        options: TrackOptions = TrackOptions(),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.laneRange = laneRange
        self._selection = .constant(nil)
        self.options = options
        self.content = content
        self.header = { EmptyView() }
        self.ruler = { _ in EmptyView() }
        self.placeholder = { _ in EmptyView() }
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollView([.vertical, .horizontal], showsIndicators: true) {
                headerlessContentView
                    .frame(minWidth: proxy.size.width, minHeight: proxy.size.height, alignment: .topLeading)
                    .overlayPreferenceValue(LanePreferenceKey.self) { value in
                        editingRegion(value)
                    }
                    .coordinateSpace(name: namespace)
            }
            .clipped()
        }
    }

    @ViewBuilder
    private var headerlessContentView: some View {
        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
            Section {
                content()
                    .environment(\.laneRange, laneRange)
                    .environment(\.trackOptions, options)
            }
        }

    }
}

extension TrackEditor where Content: View, Header == EmptyView, Ruler == EmptyView, Placeholder: View {

    public init(
        _ laneRange: Range<Int>,
        options: TrackOptions = TrackOptions(),
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder placeholder: @escaping (RegionSelection) -> Placeholder
    ) {
        self.laneRange = laneRange
        self._selection = .constant(nil)
        self.options = options
        self.content = content
        self.header = { EmptyView() }
        self.ruler = { _ in EmptyView() }
        self.placeholder = placeholder
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

    public struct Region: Identifiable, Hashable, LaneRegioning {
        public var id: String
        public var label: String
        public var start: CGFloat
        public var end: CGFloat
        public init(
            label: String,
            start: CGFloat,
            end: CGFloat
        ) {
            self.id = UUID().uuidString
            self.label = label
            self.start = start
            self.end = end
        }
        func startRegion(_ range: Range<Int>, options: TrackOptions) -> CGFloat {
            CGFloat(start)
        }
        func endRegion(_ range: Range<Int>, options: TrackOptions) -> CGFloat {
            CGFloat(end)
        }
    }

    static let data = [
        Track(id: "0", label: "Label0", regions: [
            Region(label: "0", start: 1, end: 1.1),
            Region(label: "1", start: 1.1, end: 1.2),
            Region(label: "2", start: 1.2, end: 1.3),
            Region(label: "3", start: 1.3, end: 8)
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
        ])
    ]

    struct ContentView: View {

        @State var selection: RegionSelection?

        var body: some View {
            TrackEditor(0..<20, selection: $selection) {
                ForEach(data, id: \.id) { track in
                    Lane {
                        Arrange(track.regions) { region in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.green.opacity(0.7))
                                .padding(1)
                        }
                    } header: { expand in
                        VStack {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(track.label)
                                        .bold()
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
            } header: {
                HStack {
                    Spacer()
                    Divider()
                }
                .frame(maxWidth: .infinity)
                .background(.bar)
            } ruler: { index in
                HStack {
                    Text("\(index)")
                        .padding(.horizontal, 12)
                    Spacer()
                    Divider()
                }
                .frame(maxWidth: .infinity)
                .background(.bar)
                .tag(index)
            } placeholder: { regionSelection in
                RoundedRectangle(cornerRadius: 12)
                    .fill(.blue.opacity(0.7))
                    .padding(1)
            }
        }
    }

    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
