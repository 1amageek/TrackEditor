//
//  Region.swift
//  
//
//  Created by nori on 2022/04/18.
//

import SwiftUI

struct Region<Content>: View where Content: View {

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
                Circle()
                    .fill(Color.blue)
                    .border(Color.white)
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
