//
//  Date+Extension.swift
//  FlaxLabsNotes
//
//  Created by Drew Aquino on 10/18/23.
//

import Foundation

extension Date {
  public var millisecondsSince1970: Int64 {
    Int64((self.timeIntervalSince1970 * 1000.0).rounded())
  }

  public init(milliseconds:Int) {
    self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
  }
}
