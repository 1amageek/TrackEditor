//
//  Region.swift
//  
//
//  Created by nori on 2022/04/18.
//

import SwiftUI

struct Region<Content>: View where Content: View {

    @State var scale: CGFloat = 1

    var content: () -> Content

    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .scaleEffect(scale)
            .onAppear {
                scale = 0.78
                withAnimation(.interactiveSpring(response: 0.1, dampingFraction: 0.3, blendDuration: 0)) {
                    scale = 1
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
