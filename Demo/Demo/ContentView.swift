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

    public func startRegion(_ range: Range<Int>, options: TrackEditorOptions) -> CGFloat {
        CGFloat(start)
    }

    public func endRegion(_ range: Range<Int>, options: TrackEditorOptions) -> CGFloat {
        CGFloat(end)
    }
}

struct ContentView: View {

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
//        .onLongPressDragGesture { placeholder in
//            self.placeholder = placeholder
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
