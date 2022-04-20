//
//  Region.swift
//  
//
//  Created by nori on 2022/04/18.
//

import SwiftUI

struct Region<Content>: View where Content: View {

    @Environment(\.laneRange) var laneRange: Range<Int>

    @Environment(\.trackOptions) var options: TrackOptions

    @Environment(\.trackNamespace) var namespace: Namespace

    @Environment(\.selection) var selection: Binding<RegionSelection?>

    @State var scale: CGFloat = 1

    var animation: Bool

    var content: () -> Content

    init(animation: Bool = true, @ViewBuilder _ content: @escaping () -> Content) {
        self.animation = animation
        self.content = content
    }

    var body: some View {
        content()
            .overlay {
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color.red)
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                .onChanged { value in
                                    let increment = round(value.translation.width / options.barWidth)
//                                    selection.wrappedValue?.size.width = incre
                                }
                        )
                }
            }
            .scaleEffect(scale)
            .onAppear {
                if animation {
                    scale = 0.78
                    withAnimation(.interactiveSpring(response: 0.1, dampingFraction: 0.3, blendDuration: 0)) {
                        scale = 1
                    }
                }
            }
    }
}

struct Region_Previews: PreviewProvider {

    static var previews: some View {
        Region {
            Color.gray
        }
    }
}
