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

public struct TrackEditorOptions {
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

private struct TrackEditorOptionsKey: EnvironmentKey {
    static let defaultValue: TrackEditorOptions = TrackEditorOptions()
}

private struct TrackEditorNamespaceKey: EnvironmentKey {
    static let defaultValue: Namespace = .init()
}

private struct TrackEditorEditingKey: EnvironmentKey {
    static let defaultValue: Binding<RegionSelection?> = .constant(nil)
}

extension EnvironmentValues {

    var laneRange: Range<Int> {
        get { self[LaneRangeKey.self] }
        set { self[LaneRangeKey.self] = newValue }
    }

    var trackEditorOptions: TrackEditorOptions {
        get { self[TrackEditorOptionsKey.self] }
        set { self[TrackEditorOptionsKey.self] = newValue }
    }

    var trackEditorNamespace: Namespace {
        get { self[TrackEditorNamespaceKey.self] }
        set { self[TrackEditorNamespaceKey.self] = newValue }
    }

    var selection: Binding<RegionSelection?> {
        get { self[TrackEditorEditingKey.self] }
        set { self[TrackEditorEditingKey.self] = newValue }
    }
}

final class TrackModel: ObservableObject {

    var onTrackGestureChanged: (() -> Void)?
    var onTrackGestureEneded: (() -> Void)?
}

public struct TrackEditor<Content, Header, Ruler, Placeholder> {

    @StateObject var model: TrackModel = TrackModel()

    @Namespace var namespace: Namespace.ID

    @Binding var selection: RegionSelection?

    var range: Range<Int>

    var options: TrackEditorOptions

    var content: () -> Content

    var header: () -> Header

    var ruler: (Int) -> Ruler

    var placeholder: (RegionSelection) -> Placeholder
}

extension TrackEditor: View where Content: View, Header: View, Ruler: View, Placeholder: View {

    init(
        _ range: Range<Int>,
        selection: Binding<RegionSelection?>,
        options: TrackEditorOptions = TrackEditorOptions(),
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder ruler: @escaping (Int) -> Ruler,
        @ViewBuilder placeholder: @escaping (RegionSelection) -> Placeholder,
        onTrackGestureChanged: (() -> Void)? = nil,
        onTrackGestureEneded: (() -> Void)? = nil
    ) {
        self.range = range
        self._selection = selection
        self.options = options
        self.content = content
        self.header = header
        self.ruler = ruler
        self.placeholder = placeholder
        self.model.onTrackGestureChanged = onTrackGestureChanged
        self.model.onTrackGestureEneded = onTrackGestureEneded
    }

    public init(
        _ range: Range<Int>,
        selection: Binding<RegionSelection?>,
        options: TrackEditorOptions = TrackEditorOptions(),
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder ruler: @escaping (Int) -> Ruler,
        @ViewBuilder placeholder: @escaping (RegionSelection) -> Placeholder
    ) {
        self.range = range
        self._selection = selection
        self.options = options
        self.content = content
        self.header = header
        self.ruler = ruler
        self.placeholder = placeholder
    }

    public init(
        _ range: Range<Int>,
        options: TrackEditorOptions = TrackEditorOptions(),
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder ruler: @escaping (Int) -> Ruler,
        @ViewBuilder placeholder: @escaping (RegionSelection) -> Placeholder
    ) {
        self.range = range
        self._selection = .constant(nil)
        self.options = options
        self.content = content
        self.header = header
        self.ruler = ruler
        self.placeholder = placeholder
    }

    public func onTrackGesture(_ onChanged: @escaping () -> Void, onEnded: @escaping () -> Void) -> Self {
        TrackEditor(range,
                    selection: $selection,
                    options: options,
                    content: content,
                    header: header,
                    ruler: ruler,
                    placeholder: placeholder,
                    onTrackGestureChanged: onChanged,
                    onTrackGestureEneded: onEnded
        )
    }

    var contentSize: CGSize {
        let width: CGFloat = options.barWidth * CGFloat(range.upperBound - range.lowerBound) + options.headerWidth
        let height: CGFloat = options.trackHeight
        return CGSize(width: width, height: height)
    }

    @ViewBuilder
    func editingRegion(_ value: [LanePreference]) -> some View {
        let _ = print(value)
        if let selection = selection {
            GeometryReader { geometory in

                if let a = value[selection.tag] {
                    let _ = print(geometory[a.bounds])
                }
                Region(animation: selection.id == nil) {
                    placeholder(selection)
                }
                .frame(width: selection.size.width, height: selection.size.height)
                .overlay(RegionDragGestureOverlay(id: selection.id, tag: selection.tag))
                .position(x: selection.position.x, y: selection.position.y)
            }
        }
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollView([.vertical, .horizontal], showsIndicators: true) {
                ZStack(alignment: .topLeading) {
                    LazyHStack(spacing: 0) {
                        Section {
                            ForEach(range, id: \.self) { index in
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
                .environment(\.laneRange, range)
                .environment(\.trackEditorOptions, options)
                .environment(\.trackEditorNamespace, _namespace)
                .environment(\.selection, $selection)
            }
            .clipped()
        }
        .environmentObject(model)
    }

    @ViewBuilder
    private var contentView: some View {
        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
            Section {
                content()
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
                .frame(height: options.rulerHeight)
            }
        }
    }
}

extension TrackEditor where Content: View, Header: View, Ruler: View, Placeholder == EmptyView {

    public init(
        _ range: Range<Int>,
        options: TrackEditorOptions = TrackEditorOptions(),
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder ruler: @escaping (Int) -> Ruler
    ) {
        self.range = range
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
                            ForEach(range, id: \.self) { index in
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
        _ range: Range<Int>,
        options: TrackEditorOptions = TrackEditorOptions(),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.range = range
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
                    .environment(\.laneRange, range)
                    .environment(\.trackEditorOptions, options)
            }
        }

    }
}

extension TrackEditor where Content: View, Header == EmptyView, Ruler == EmptyView, Placeholder: View {

    public init(
        _ range: Range<Int>,
        options: TrackEditorOptions = TrackEditorOptions(),
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder placeholder: @escaping (RegionSelection) -> Placeholder
    ) {
        self.range = range
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
        func startRegion(_ range: Range<Int>, options: TrackEditorOptions) -> CGFloat {
            CGFloat(start)
        }
        func endRegion(_ range: Range<Int>, options: TrackEditorOptions) -> CGFloat {
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
            } placeholder: { RegionSelection in
                RoundedRectangle(cornerRadius: 12)
                    .fill(.blue.opacity(0.7))
                    .padding(1)
                    .overlay {
                        Text("\(RegionSelection.id ?? "")")
                    }
            }
        }
    }

    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
