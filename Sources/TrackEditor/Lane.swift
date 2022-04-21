//
//  SwiftUIView.swift
//  
//
//  Created by nori on 2022/04/11.
//

import SwiftUI

private struct LaneNamespaceKey: EnvironmentKey {
    static let defaultValue: Namespace = .init()
}

private struct LaneIDKey: EnvironmentKey {
    static let defaultValue: String = UUID().uuidString
}

extension EnvironmentValues {

    var laneNamespace: Namespace {
        get { self[LaneNamespaceKey.self] }
        set { self[LaneNamespaceKey.self] = newValue }
    }

    var laneID: String {
        get { self[LaneIDKey.self] }
        set { self[LaneIDKey.self] = newValue }
    }
}

public struct Lane<Content, Header, SubLane> {

    @Environment(\.laneRange) var laneRange: Range<Int>

    @Environment(\.trackOptions) var options: TrackOptions

    @Environment(\.trackNamespace) var namespace: Namespace

    @Environment(\.selection) var selection: Binding<RegionSelection?>

    @Namespace var laneNamespace: Namespace.ID

    @State var isSubTracksExpanded: Bool = false

    var laneID: String = UUID().uuidString

    var content: () -> Content

    var header: (ExpandAction) -> Header

    var subLane: () -> SubLane

    var trackEditorAreaWidth: CGFloat { options.barWidth * CGFloat(laneRange.count) }
}

extension Lane: View where Content: View, Header: View, SubLane: View {

    public init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping (ExpandAction) -> Header,
        @ViewBuilder subLane: @escaping () -> SubLane
    ) {
        self.content = content
        self.header = header
        self.subLane = subLane
    }

    init(
        _ laneID: String,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping (ExpandAction) -> Header,
        @ViewBuilder subLane: @escaping () -> SubLane
    ) {
        self.laneID = laneID
        self.content = content
        self.header = header
        self.subLane = subLane
    }

    public func tag(_ tag: String) -> some View {
        Lane(tag, content: content, header: header, subLane: subLane)
    }

    public var body: some View {
        VStack(spacing: 0) {
            lane()
            subTrackView()
        }
    }

    @ViewBuilder
    func lane() -> some View {
        let expand: ExpandAction = ExpandAction {
            withAnimation {
                self.isSubTracksExpanded.toggle()
            }
        }
        LazyHStack(alignment: .top, spacing: 0, pinnedViews: .sectionHeaders) {
            Section {
                content()
                    .environment(\.laneNamespace, _laneNamespace)
                    .environment(\.laneID, laneID)
            } header: {
                header(expand)
                    .frame(width: options.headerWidth, height: options.trackHeight)
            }
        }
        .frame(width: trackEditorAreaWidth + options.headerWidth, height: options.trackHeight, alignment: .leading)
        .coordinateSpace(name: laneNamespace)
        .backgroundPreferenceValue(RegionPreferenceKey.self) { value in
            Color.clear.anchorPreference(key: LanePreferenceKey.self, value: .bounds, transform: { [LanePreference(id: laneID, bounds: $0, regionPreferences: value)] })
        }
    }

    @ViewBuilder
    func subTrackView() -> some View {
        if isSubTracksExpanded {
            subLane()
        }
    }
}

extension Lane where Content: View, Header: View, SubLane == EmptyView {

    public init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping (ExpandAction) -> Header
    ) {
        self.content = content
        self.header = header
        self.subLane = { EmptyView() }
    }
}

public struct Arrange<Data, Content> {

    @Environment(\.laneRange) var laneRange: Range<Int>

    @Environment(\.trackOptions) var options: TrackOptions

    @Environment(\.selection) var selection: Binding<RegionSelection?>

    @Environment(\.trackNamespace) var namespace: Namespace

    @Environment(\.laneID) var laneID: String

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
                .anchorPreference(key: RegionPreferenceKey.self, value: .bounds, transform: { [RegionPreference(id: "\(element.id)", laneID: laneID, bounds: $0)] })
                .padding(.leading, padding)
        }
    }

    func position(data: [Data], element: Data) -> (width: CGFloat, padding: CGFloat) {
        let options = options
        let laneRange = laneRange
        let index = data.firstIndex(where: { $0.id == element.id })!
        let prevIndex = index - 1
        let prevEnd = prevIndex < 0 ? CGFloat(laneRange.lowerBound) : sortedData[prevIndex].endRegion(laneRange, options: options)
        let start = element.startRegion(laneRange, options:options)
        let end = element.endRegion(laneRange, options:options)
        let leadingPadding = CGFloat(start - prevEnd) * options.barWidth
        let width = CGFloat(end - start) * options.barWidth
        return (width: width, padding: leadingPadding)
    }
}

public struct EqualParts<Content> {

    @Environment(\.laneRange) var laneRange: Range<Int>

    @Environment(\.trackOptions) var options: TrackOptions

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
