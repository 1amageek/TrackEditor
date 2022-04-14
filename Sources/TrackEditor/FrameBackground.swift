//
//  FrameBackground.swift
//  
//
//  Created by nori on 2022/04/13.
//

import SwiftUI

struct FrameBackground: View {

    enum DragState {
        case inactive
        case pressing
        case dragging(translation: CGSize)

        var translation: CGSize {
            switch self {
                case .inactive, .pressing:
                    return .zero
                case .dragging(let translation):
                    return translation
            }
        }

        var isActive: Bool {
            switch self {
                case .inactive:
                    return false
                case .pressing, .dragging:
                    return true
            }
        }

        var isDragging: Bool {
            switch self {
                case .inactive, .pressing:
                    return false
                case .dragging:
                    return true
            }
        }
    }

    @GestureState var dragState = DragState.inactive
//    @Binding var viewState: PlaceholderViewState?
//
//    init(_ viewState: Binding<PlaceholderViewState?>) {
//        self._viewState = viewState
//    }

    var id: String

    var index: Int

    @State var text: String = "www"

    var body: some View {
        let minimumLongPressDuration = 0.5
        let longPressDrag = LongPressGesture(minimumDuration: minimumLongPressDuration)
            .sequenced(before: DragGesture())
            .updating($dragState) { value, state, transaction in
                switch value {
                        // Long press begins.
                    case .first(true):
                        self.text = "first"
                        state = .pressing
                        // Long press confirmed, dragging may begin.
                    case .second(true, let drag):
                        self.text = "\(drag)"
                        state = .dragging(translation: drag?.translation ?? .zero)
                        // Dragging ended or the long press cancelled.
                    default:
                        state = .inactive
                }
            }
            .onEnded { value in
                guard case .second(true, let drag?) = value else { return }
                self.text = "\(drag)"
//                self.viewState?.offset.width += drag.translation.width
//                self.viewState?.offset.height += drag.translation.height
            }

        return GeometryReader { proxy in
            HStack(spacing: 0) {
                Divider()
                Color.red
                    .overlay {
                        Text(text)
                    }
            }
            .contentShape(Rectangle())
//            .animation(nil)
//            .shadow(radius: dragState.isActive ? 8 : 0)
//            .animation(.linear(duration: minimumLongPressDuration))
//            .gesture(longPressDrag)
            .anchorPreference(key: FramePreferenceKey.self, value: .bounds, transform: { [FramePreference(trackID: id, index: index, bounds: $0)] })
        }
    }
}

//struct FrameBackground_Previews: PreviewProvider {
//    static var previews: some View {
//        FrameBackground()
//    }
//}
