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
    public var laneID: String
    public var label: String
    public var start: CGFloat
    public var end: CGFloat

    public init(
        id: String,
        laneID: String,
        label: String,
        start: CGFloat,
        end: CGFloat
    ) {
        self.id = id
        self.laneID = laneID
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
        Region(id: "0", laneID: "0", label: "0", start: 0, end: 1),
        Region(id: "1", laneID: "0", label: "1", start: 2, end: 3),
        Region(id: "2", laneID: "0", label: "2", start: 4, end: 5),
        Region(id: "4", laneID: "1", label: "0", start: 0, end: 1),
        Region(id: "5", laneID: "1", label: "1", start: 2, end: 3),
        Region(id: "6", laneID: "1", label: "2", start: 4, end: 5)
    ]

    var body: some View {
        TrackEditor(0..<10, selection: $selection) {
            ForEach(["0", "1"], id: \.self) { laneID in
                let data = regions.filter({ $0.laneID == laneID })
                Lane {
                    Arrange(data) { region in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.blue.opacity(0.7))
                            .padding(1)
                            .onTapGesture {
                                print("Tap")
                            }
                    }
                } header: { expand in
                    VStack {
                        Spacer()
                        Divider()
                    }
                    .frame(maxHeight: .infinity)
                    .background(Color.white)
                }
                .tag(laneID)
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
        } placeholder: { id in
            RoundedRectangle(cornerRadius: 12)
                .fill(.blue)
                .padding(1)
                .onTapGesture {
                    print("Tap")
                }
        }
        .onTrackDragGestureEnded(onEnded: { address, moveAction in
            moveAction(address: address)
        })
        .onChange(of: selection) { newValue in
            if let selection = newValue {
                if let id = selection.id {
                    if case .focused = selection.gestureState {
                        if let index = self.regions.firstIndex(where: { $0.id == String(describing: id) }) {
                            self.regions[index].laneID = String(describing: selection.laneID)
                            self.regions[index].start = selection.period.lowerBound
                            self.regions[index].end = selection.period.upperBound
                        }
                    }
                } else {
                    if case .focused = selection.gestureState {
//                        print(selection)
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
