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

public struct Editing: Identifiable {
    public var id: String
    public var position: CGPoint
    public var size: CGSize
    public var period: Range<CGFloat>
}

private struct TrackEditorLaneRangeKey: EnvironmentKey {
    static let defaultValue: Range<Int> = 0..<100
}

private struct TrackEditorOptionsKey: EnvironmentKey {
    static let defaultValue: TrackEditorOptions = TrackEditorOptions()
}

private struct TrackEditorNamespaceKey: EnvironmentKey {
    static let defaultValue: Namespace = .init()
}

private struct TrackEditorGestureKey: EnvironmentKey {
    static let defaultValue: GestureState<TrackEditorGestureState> = GestureState(initialValue: .inactive)
}

private struct TrackEditorEditingKey: EnvironmentKey {
    static let defaultValue: Binding<Editing?> = .constant(nil)
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

    var trackEditorNamespace: Namespace {
        get { self[TrackEditorNamespaceKey.self] }
        set { self[TrackEditorNamespaceKey.self] = newValue }
    }

    var gestureState: GestureState<TrackEditorGestureState> {
        get { self[TrackEditorGestureKey.self] }
        set { self[TrackEditorGestureKey.self] = newValue }
    }

    var editState: Binding<Editing?> {
        get { self[TrackEditorEditingKey.self] }
        set { self[TrackEditorEditingKey.self] = newValue }
    }
}

public struct TrackEditor<Content, Header, Ruler, Placeholder> {

    @GestureState var gestureState: TrackEditorGestureState = .inactive

    @State var editState: Editing?

    @State var viewState: (position: CGPoint, size: CGSize, trackID: Int, regionPlaceholder: RegionPlaceholder)?

    @Namespace var namespace: Namespace.ID

    var range: Range<Int>

    var options: TrackEditorOptions

    var content: () -> Content

    var header: () -> Header

    var ruler: (Int) -> Ruler

    var placeholder: (Int, RegionPlaceholder) -> Placeholder

    var _onGestureEnded: ((RegionPlaceholder) -> Void)?

//    func position(trackID: Int, index: Int) -> CGPoint {
//        let midX: CGFloat = options.barWidth / 2
//        let midY: CGFloat = options.trackHeight / 2
//        let offsetX: CGFloat = midX + options.headerWidth
//        let offsetY: CGFloat = midY + options.rulerHeight
//        let x: CGFloat = CGFloat(index) * options.barWidth + offsetX
//        let y: CGFloat = CGFloat(trackID) * options.trackHeight + offsetY
//        return CGPoint(x: x, y: y)
//    }
//
//    func longPressDrag(proxy: GeometryProxy) -> some Gesture {
//        let minimumLongPressDuration = 0.33
//        return LongPressGesture(minimumDuration: minimumLongPressDuration)
//            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
//            .updating($gestureState) { value, state, transaction in
//                switch value {
//                    case .first(true): state = .pressing
//                    case .second(true, let drag):
//                        if let drag = drag {
//                            state = .dragging(translation: drag.translation, startLocation: drag.startLocation)
//                        }
//                    default: state = .inactive
//                }
//            }
//            .onEnded { value in
//                guard case .second(true, let drag?) = value else { return }
//                let _x: CGFloat = drag.startLocation.x + drag.translation.width
//                let _y: CGFloat = drag.startLocation.y + drag.translation.height
//                let midX: CGFloat = options.barWidth / 2
//                let midY: CGFloat = options.trackHeight / 2
//                let offsetX: CGFloat = midX + options.headerWidth
//                let offsetY: CGFloat = midY + options.rulerHeight
//                let rangeX: Range<CGFloat> = offsetX..<(proxy.size.width - midX)
//                let rangeY: Range<CGFloat> = offsetY..<(proxy.size.height - midY)
//                let x = max(min(rangeX.upperBound, _x), rangeX.lowerBound)
//                let y = max(min(rangeY.upperBound, _y), rangeY.lowerBound)
//                let trackID = Int(round((y - offsetY) / options.trackHeight))
//                let _index = Int(round((x - offsetX) / options.barWidth)) + range.lowerBound
//                let index = min(max(_index, range.lowerBound), range.upperBound)
//                let position: CGPoint = position(trackID: trackID, index: index)
//                let period: Range<Int> = index..<(index + 1)
//                let regionPlaceholder: RegionPlaceholder = RegionPlaceholder(period: period, action: {
//                    viewState = nil
//                })
//                viewState = (
//                    position: position,
//                    size: CGSize(width: options.barWidth, height: options.trackHeight),
//                    trackID: trackID,
//                    regionPlaceholder: regionPlaceholder
//                )
//                if let _onGestureEnded = _onGestureEnded {
//                    _onGestureEnded(regionPlaceholder)
//                }
//            }
//    }
}

extension TrackEditor: View where Content: View, Header: View, Ruler: View, Placeholder: View {

    public init(
        _ range: Range<Int>,
        options: TrackEditorOptions = TrackEditorOptions(),
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder ruler: @escaping (Int) -> Ruler,
        @ViewBuilder placeholder: @escaping (Int, RegionPlaceholder) -> Placeholder
    ) {
        self.range = range
        self.options = options
        self.content = content
        self.header = header
        self.ruler = ruler
        self.placeholder = placeholder
    }

    init(
        _ range: Range<Int>,
        options: TrackEditorOptions = TrackEditorOptions(),
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder ruler: @escaping (Int) -> Ruler,
        @ViewBuilder placeholder: @escaping (Int, RegionPlaceholder) -> Placeholder,
        onGestureEnded: @escaping (RegionPlaceholder) -> Void
    ) {
        self.range = range
        self.options = options
        self.content = content
        self.header = header
        self.ruler = ruler
        self.placeholder = placeholder
        self._onGestureEnded = onGestureEnded
    }

    public func onLongPressDragGesture(_ action: @escaping (RegionPlaceholder) -> Void) -> some View {
        TrackEditor(range, options: options, content: content, header: header, ruler: ruler, placeholder: placeholder, onGestureEnded: action)
    }

    var contentSize: CGSize {
        let width: CGFloat = options.barWidth * CGFloat(range.upperBound - range.lowerBound) + options.headerWidth
        let height: CGFloat = options.trackHeight
        return CGSize(width: width, height: height)
    }

    func placeholderFrame(proxy: GeometryProxy) -> (position: CGPoint, size: CGSize, trackID: Int, regionPlaceholder: RegionPlaceholder)? {
        if gestureState.isDragging {
            let _x = gestureState.startLocation.x + gestureState.translation.width
            let _y = gestureState.startLocation.y + gestureState.translation.height
            let midX: CGFloat = options.barWidth / 2
            let midY: CGFloat = options.trackHeight / 2
            let rangeX: Range<CGFloat> = (options.headerWidth + midX)..<proxy.size.width - midX
            let rangeY: Range<CGFloat> = (options.rulerHeight + midY)..<proxy.size.height - midY
            let x = max(min(rangeX.upperBound, _x), rangeX.lowerBound)
            let y = max(min(rangeY.upperBound, _y), rangeY.lowerBound)
            let trackID = Int(round((y - midY - options.rulerHeight) / options.trackHeight))
            let _index = Int(round((x - midX - options.headerWidth) / options.barWidth)) + range.lowerBound
            let index = min(max(_index, range.lowerBound), range.upperBound)
            let period = index..<(index + 1)
            let regionPlaceholder: RegionPlaceholder = RegionPlaceholder(period: period, action: {
                viewState = nil
            })
            return (
                position: CGPoint(x: x, y: y),
                size: CGSize(width: options.barWidth, height: options.trackHeight),
                trackID: trackID,
                regionPlaceholder: regionPlaceholder
            )
        }
        return viewState
    }

    @ViewBuilder
    var placeholder: some View {
        switch gestureState {
            case .inactive: EmptyView()
            case .dragging(let id, let dragGesture, let frame):
                Color.red
                    .frame(width: frame.width, height: frame.height)
                    .position(x: frame.midX, y: frame.maxY)
            case .pressing: EmptyView()
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
                    .contentShape(Rectangle())
                    .padding(.leading, options.headerWidth)

                    contentView
                        .frame(width: contentSize.width)
                        .contentShape(Rectangle())
                        .overlay {
                            placeholder
                        }
                        .coordinateSpace(name: namespace)
//                        .overlay {
//                            GeometryReader { contentGeometory in
//                                Rectangle()
//                                    .fill(Color.clear)
//                                    .contentShape(Rectangle())
//                                    .onTapGesture {}
//                                    .gesture(longPressDrag(proxy: contentGeometory))
//                                    .overlay {
//                                        if let (position, size, trackID, regionPlaceholder) = placeholderFrame(proxy: contentGeometory) {
//                                            placeholder(trackID, regionPlaceholder)
//                                                .frame(width: size.width, height: size.height)
//                                                .position(x: position.x, y: position.y)
//                                        }
//                                    }
//                            }
//                        }
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
                    .environment(\.trackEditorNamespace, _namespace)
                    .environment(\.gestureState, $gestureState)
                    .environment(\.editState, $editState)
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

//extension TrackEditor where Content: View, Header: View, Ruler: View, Placeholder == EmptyView {
//
//    public init(
//        _ range: Range<Int>,
//        options: TrackEditorOptions = TrackEditorOptions(),
//        @ViewBuilder content: @escaping () -> Content,
//        @ViewBuilder header: @escaping () -> Header,
//        @ViewBuilder ruler: @escaping (Int) -> Ruler
//    ) {
//        self.range = range
//        self.options = options
//        self.content = content
//        self.header = header
//        self.ruler = ruler
//        self.placeholder = { _, _ in EmptyView() }
//    }
//
//    public var body: some View {
//        GeometryReader { proxy in
//            ScrollView([.vertical, .horizontal], showsIndicators: true) {
//                ZStack(alignment: .topLeading) {
//                    LazyHStack(spacing: 0) {
//                        Section {
//                            ForEach(range, id: \.self) { index in
//                                HStack(spacing: 0) {
//                                    Divider()
//                                    Spacer()
//                                }
//                                .frame(width: options.barWidth)
//                            }
//                        }
//                    }
//                    .contentShape(Rectangle())
//                    .padding(.leading, options.headerWidth)
//
//                    GeometryReader { contentGeometory in
//                        contentView
//                            .frame(width: contentSize.width)
//                            .contentShape(Rectangle())
////                            .onTapGesture {}
////                            .gesture(longPressDrag(proxy: contentGeometory))
//                    }
//                }
//                .frame(minWidth: proxy.size.width, minHeight: proxy.size.height, alignment: .topLeading)
//            }
//            .clipped()
//        }
//    }
//}
//
//extension TrackEditor where Content: View, Header == EmptyView, Ruler == EmptyView, Placeholder == EmptyView {
//
//    public init(
//        _ range: Range<Int>,
//        options: TrackEditorOptions = TrackEditorOptions(),
//        @ViewBuilder content: @escaping () -> Content
//    ) {
//        self.range = range
//        self.options = options
//        self.content = content
//        self.header = { EmptyView() }
//        self.ruler = { _ in EmptyView() }
//        self.placeholder = { _, _ in EmptyView() }
//    }
//
//    public var body: some View {
//        GeometryReader { proxy in
//            ScrollView([.vertical, .horizontal], showsIndicators: true) {
//                headerlessContentView
//                    .frame(minWidth: proxy.size.width, minHeight: proxy.size.height, alignment: .topLeading)
//            }
//            .clipped()
//        }
//    }
//
//    @ViewBuilder
//    private var headerlessContentView: some View {
//        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
//            Section {
//                content()
//                    .environment(\.laneRange, range)
//                    .environment(\.trackEditorOptions, options)
//            }
//        }
//    }
//}


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

        @State var placeholder: RegionPlaceholder?

        var body: some View {
            TrackEditor(0..<20) {
                ForEach(data, id: \.id) { track in
                    TrackLane {
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
            } placeholder: { track, regionPlaceholder in
                RoundedRectangle(cornerRadius: 12)
                    .fill(.blue.opacity(0.7))
                    .padding(1)
                    .overlay {
                        Text("\(track) \(regionPlaceholder.period.lowerBound)")
                    }
            }
            .onLongPressDragGesture { placeholder in
                self.placeholder = placeholder
            }
            .sheet(item: $placeholder, content: { placeholder in
                VStack {
                    Button {
                        placeholder.hide()
                    } label: {
                        Text("HIDE")
                    }
                }
            })
        }
    }

    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
