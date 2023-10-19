//
//  Exception.swift
//  FlaxLabsNotes
//
//  Created by Drew Aquino on 10/18/23.
//

import Foundation

public struct Exception: Error {
  public let underlyingError: Error
  public var localizedDescription: String { self.underlyingError.localizedDescription }
  public init(_ error: Error) {
    if let error = error as? Exception {
      self = error
    } else {
      self.underlyingError = error
    }
  }
}

