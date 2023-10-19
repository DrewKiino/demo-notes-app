//
//  FirebaseService.swift
//  FlaxLabsNotes
//
//  Created by Drew Aquino on 10/17/23.
//

import Foundation
import FirebaseCore
import FirebaseDatabase
import Combine

public enum FirebaseServiceError: Error {
  case invalidWire(Error)
}

public protocol FirebaseService {
  var database: DatabaseReference { get }
  func configure()
}

public class FirebaseServiceImpl: FirebaseService {
  
  public private(set) lazy var database: DatabaseReference = Database.database().reference()
  
  public init() {}
  
  public func configure() {
    FirebaseApp.configure()
    // quiet console for now
    FirebaseConfiguration.shared.setLoggerLevel(.min)
  }
}
