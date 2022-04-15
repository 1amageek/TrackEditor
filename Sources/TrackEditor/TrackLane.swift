//
//  SwiftUIView.swift
//  
//
//  Created by nori on 2022/04/11.
//

import SwiftUI

private struct TrackLaneNamespaceKey: EnvironmentKey {
    static let defaultValue: Namespace = .init()
}

extension EnvironmentValues {

    var trackLaneNamespace: Namespace {
        get { self[TrackLaneNamespaceKey.self] }
        set { self[TrackLaneNamespaceKey.self] = newValue }
    }
}

public struct TrackLane<Content, Header, SubTrackLane> {

    @Environment(\.laneRange) var laneRange: Range<Int>

    @Environment(\.trackEditorOptions) var options: TrackEditorOptions

    @Environment(\.trackEditorNamespace) var namespace: Namespace

    @Environment(\.gestureState) var gestureState: GestureState<TrackEditorGestureState>

//    @Environment(\.editState) var editState: Binding<Editing?>

    @Namespace var trackLaneNamespace: Namespace.ID

    @State var isSubTracksExpanded: Bool = false

    var content: () -> Content

    var header: (ExpandAction) -> Header

    var subTrackLane: () -> SubTrackLane

    var trackEditorAreaWidth: CGFloat { options.barWidth * CGFloat(laneRange.count) }

    func longPressDragGesture(_ preferenceValue: [RegionPreference], geometory: GeometryProxy) -> some Gesture {
        let minimumLongPressDuration = 0.5
        return LongPressGesture(minimumDuration: minimumLongPressDuration)
            .sequenced(before: DragGesture())
            .updating(gestureState) { value, state, transaction in
                switch value {
                    case .first(true):
                        state = .pressing
                    case .second(true, let drag):
                        if let drag = drag {
                            if let index = preferenceValue.firstIndex(where: { preference in
                                let frame = geometory[preference.bounds]
                                return frame.contains(drag.startLocation)
                            }) {
                                let preference = preferenceValue[index]
                                let frame = geometory[preference.bounds].offsetBy(dx: drag.translation.width, dy: drag.translation.height)
                                state = .dragging(id: preference.id, dragGesture: drag, frame: frame)
                            } else {
                                let frame = CGRect(x: drag.startLocation.x, y: drag.startLocation.y, width: options.barWidth, height: options.trackHeight).offsetBy(dx: drag.translation.width, dy: drag.translation.height)
                                state = .dragging(id: nil, dragGesture: drag, frame: frame)
                            }
                        }
                    default:
                        state = .inactive
                }
            }
            .onEnded { value in
                guard case .second(true, let drag?) = value else { return }
//                self.viewState.width += drag.translation.width
//                self.viewState.height += drag.translation.height
            }
    }
}

extension TrackLane: View where Content: View, Header: View, SubTrackLane: View {

    public init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping (ExpandAction) -> Header,
        @ViewBuilder subTrackLane: @escaping () -> SubTrackLane
    ) {
        self.content = content
        self.header = header
        self.subTrackLane = subTrackLane
    }

    public var body: some View {
        VStack(spacing: 0) {
            trackLane()
                .frame(width: trackEditorAreaWidth + options.headerWidth, height: options.trackHeight, alignment: .leading)
                .coordinateSpace(name: trackLaneNamespace)
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
                content()
                    .environment(\.trackLaneNamespace, _trackLaneNamespace)
            } header: {
                header(expand)
                    .frame(width: options.headerWidth, height: options.trackHeight)
            }
        }
        .overlayPreferenceValue(RegionPreferenceKey.self) { value in
            GeometryReader { geometory in
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(longPressDragGesture(value, geometory: geometory))
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

extension TrackLane where Content: View, Header: View, SubTrackLane == EmptyView {

    public init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping (ExpandAction) -> Header
    ) {
        self.content = content
        self.header = header
        self.subTrackLane = { EmptyView() }
    }
}

public struct Arrange<Data, Content> {

    @Environment(\.laneRange) var laneRange: Range<Int>

    @Environment(\.trackEditorOptions) var options: TrackEditorOptions

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
                .anchorPreference(key: RegionPreferenceKey.self, value: .bounds, transform: { [RegionPreference(id: element.id, bounds: $0)] })
                .padding(.leading, padding)
        }
    }

    func position(data: [Data], element: Data) -> (width: CGFloat, padding: CGFloat) {
        let index = data.firstIndex(where: { $0.id == element.id })!
        let prevIndex = index - 1
        let prevEnd = prevIndex < 0 ? CGFloat(laneRange.lowerBound) : sortedData[prevIndex].endRegion(laneRange, options:options)
        let start = element.startRegion(laneRange, options:options)
        let end = element.endRegion(laneRange, options:options)
        let leadingPadding = CGFloat(start - prevEnd) * options.barWidth
        let width = CGFloat(end - start) * options.barWidth
        return (width: width, padding: leadingPadding)
    }
}

public struct EqualParts<Content> {

    @Environment(\.laneRange) var laneRange: Range<Int>

    @Environment(\.trackEditorOptions) var options: TrackEditorOptions

    var number: Int

    var content: (Int) -> Content
}

extension EqualParts: View where Content: View {

    public init(_ number: Int, @ViewBuilder content: @escaping (Int) -> Content) {
        self.number = number
        self.content = content
    }

    var width: CGFloat {
        CGFloat(laneRange.upperBound - laneRange.lowerBound) * options.barWidth / CGFloat(number)
    }

    public var body: some View {
        ForEach(0..<number, id: \.self) { index in
            content(index)
                .frame(width: width)
        }
    }
}

struct TrackLane_Previews: PreviewProvider {

    public struct Region: Identifiable, LaneRegioning {
        public var id: String
        public var label: String
        public var start: CGFloat
        public var end: CGFloat
        public init(
            id: String,
            label: String,
            start: CGFloat,
            end: CGFloat
        ) {
            self.id = id
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

    struct ContentView: View {

        @State var placeholder: RegionPlaceholder?

        let regions: [Region] = [
            Region(id: "0", label: "0", start: 0, end: 1),
            Region(id: "1", label: "1", start: 2, end: 3),
            Region(id: "2", label: "2", start: 4, end: 5)
        ]

        var body: some View {
            TrackEditor(0..<20) {
                TrackLane {
                    Arrange(regions) { region in
                        Color.green
                    }
                } header: { expand in
                    VStack {
                        Spacer()
                        Divider()
                    }
                    .frame(maxHeight: .infinity)
                    .background(Color.white)
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
    }
}
