//
//  ContentView.swift
//  Demo
//
//  Created by nori on 2022/04/15.
//

import SwiftUI
import TrackEditor

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

    public func startRegion(_ range: Range<Int>, options: TrackOptions) -> CGFloat {
        CGFloat(start)
    }

    public func endRegion(_ range: Range<Int>, options: TrackOptions) -> CGFloat {
        CGFloat(end)
    }
}

struct ContentView: View {

    @State var selection: RegionSelection?

    @State var regions: [Region] = [
        Region(id: "0", label: "0", start: 0, end: 1),
        Region(id: "1", label: "1", start: 2, end: 3),
        Region(id: "2", label: "2", start: 4, end: 5)
    ]

    var body: some View {
        TrackEditor(0..<20, selection: $selection) {
            Lane {
                Arrange(regions) { region in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.blue.opacity(0.7))
                        .padding(1)                        
                }
            } header: { expand in
                VStack {
                    Spacer()
                    Divider()
                }
                .frame(maxHeight: .infinity)
                .background(Color.white)
            }
            .tag("a")
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
        } placeholder: { id in
            RoundedRectangle(cornerRadius: 12)
                .fill(.blue)
                .padding(1)
        }
//        .onTrackGesture({
//            
//        }, onEnded: { address, moveAction in
//            moveAction(address: address)
//        })
        .onChange(of: selection) { newValue in
            if let selection = newValue, let id = selection.id {
                if case .focused = selection.gestureState {
                    if let index = self.regions.firstIndex(where: { $0.id == String(describing: id) }) {
                        self.regions[index].start = selection.period.lowerBound
                        self.regions[index].end = selection.period.upperBound
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
