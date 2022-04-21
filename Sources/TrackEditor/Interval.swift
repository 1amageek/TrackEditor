//
//  Interval.swift
//  
//
//  Created by nori on 2022/04/21.
//

import Foundation

public enum Interval {
    case month(Int)
    case day(Int)
    case hour(Int)
    case minute(Int)
    case second(Int)
}

extension Interval {

    public func date(at location: Double, laneRange: Range<Int>, options: TrackOptions) -> Date {
        let calendar = Foundation.Calendar(identifier: .iso8601)
        switch self {
            case .month(let int):
                let date = calendar.dateComponents([.calendar, .timeZone, .year, .month], from: options.reference.date!).date!
                let value = location * Double(int)
                return calendar.date(byAdding: .month, value: Int(value), to: date)!
            case .day(let int):
                let date = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day], from: options.reference.date!).date!
                let value = location * Double(int)
                return calendar.date(byAdding: .day, value: Int(value), to: date)!
            case .hour(let int):
                let date = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day, .hour], from: options.reference.date!).date!
                let value = location * Double(int)
                return calendar.date(byAdding: .hour, value: Int(value), to: date)!
            case .minute(let int):
                let date = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day, .hour, .minute], from: options.reference.date!).date!
                let value = location * Double(int)
                return calendar.date(byAdding: .minute, value: Int(value), to: date)!
            case .second(let int):
                let date = calendar.dateComponents([.calendar, .timeZone, .year, .month, .day, .hour, .minute, .second], from: options.reference.date!).date!
                let value = location * Double(int)
                return calendar.date(byAdding: .second, value: Int(value), to: date)!
        }
    }
}
