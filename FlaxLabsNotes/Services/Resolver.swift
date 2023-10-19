//
//  Resolver.swift
//  FlaxLabsNotes
//
//  Created by Drew Aquino on 10/17/23.
//

import Foundation
import FireboltSwift

public protocol Resolver: ResolverProtocol {}

/// This Resolver allows us to manage our dependencies in a organized manner
public class ResolverImpl: FireboltSwift.Resolver, Resolver {
  public init() {
    super.init()
    self.configureDependencies()
  }
  
  private func configureDependencies() {
    self.register(expect: FirebaseService.self) { (resolver: ResolverImpl) in
      FirebaseServiceImpl()
    }
    self.register(expect: NotesService.self) { (resolver: ResolverImpl) in
      NotesServiceImpl(resolver: resolver)
    }
  }
}
