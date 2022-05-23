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
