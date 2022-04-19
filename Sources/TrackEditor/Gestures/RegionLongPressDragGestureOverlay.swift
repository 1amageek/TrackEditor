////
////  RegionLongPressDragGestureOverlay.swift
////  
////
////  Created by nori on 2022/04/17.
////
//
//import SwiftUI
//
//struct RegionLongPressDragGestureOverlay: View {
//
//    @Environment(\.laneRange) var laneRange: Range<Int>
//
//    @Environment(\.trackOptions) var options: TrackOptions
//
//    @Environment(\.selection) var selection: Binding<RegionSelection?>
//
//    @Environment(\.onRegionDragGestureChanged) var onRegionDragGestureChanged: (() -> Void)?
//
//    @Environment(\.onRegionDragGestureEnded) var onRegionDragGestureEnded: ((RegionAddress, RegionMoveAction) -> Void)?
//
//    @Environment(\.trackNamespace) var namespace: Namespace
//
//    var regionID: String?
//
//    var laneID: AnyHashable
//
//    var preferenceValue: [LanePreference]
//
//    func period(for frame: CGRect) -> Range<CGFloat> {
//        let start = round((frame.minX - options.headerWidth) / options.barWidth)
//        let end = round((frame.maxX - options.headerWidth) / options.barWidth)
//        return start..<end
//    }
//
//    var body: some View {
//        GeometryReader { proxy in
//            let frame = proxy.frame(in: .named(namespace.wrappedValue))
//            let size = proxy.size
//            Color.clear
//                .contentShape(Rectangle())
//                .gesture(
//                    LongPressGesture(minimumDuration: 0.3)
//                        .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
//                        .onChanged { value in
//                            if selection.wrappedValue?.state != .focused {
//                                switch value {
//                                    case .first(true): break
//                                    case .second(true, let drag):
//                                        if let drag = drag {
//                                            LaneDragGestureHandler(laneRange: laneRange, options: options, onRegionDragGestureChanged: onRegionDragGestureChanged, onRegionDragGestureEnded: onRegionDragGestureEnded)
//                                                .onDragGestureChanged(frame: frame, gesture: drag, geometoryProxy: proxy) { position, size, period in
//                                                    self.selection.wrappedValue = RegionSelection(id: regionID, laneID: laneID, position: position, size: size, offset: .zero, period: period, state: .dragging)
//                                                }
//                                        } else {
//                                            let position = CGPoint(x: frame.midX, y: frame.midY)
//                                            let period = period(for: frame)
//                                            selection.wrappedValue = RegionSelection(id: regionID, laneID: laneID, position: position, size: size, offset: .zero, period: period, state: .pressing)
//                                        }
//                                    default: break
//                                }
//                            }
//                        }
//                        .onEnded { value in
//                            if selection.wrappedValue?.state != .focused {
//                                guard case .second(true, let drag?) = value else { return }
//                                LaneDragGestureHandler(laneRange: laneRange, options: options, onRegionDragGestureChanged: onRegionDragGestureChanged, onRegionDragGestureEnded: onRegionDragGestureEnded)
//                                    .onDragGestureEnded(id: regionID, laneID: laneID, frame: frame, gesture: drag, geometoryProxy: proxy, lanePreferences: preferenceValue) { value in
//                                        withAnimation(.interactiveSpring(response: 0.1, dampingFraction: 0.6, blendDuration: 0)) {
//                                            selection.wrappedValue = value
//                                        }
//                                    }
//                            } else {
//                                self.selection.wrappedValue = nil
//                            }
//                        }
//                )
//        }
//    }
//}
