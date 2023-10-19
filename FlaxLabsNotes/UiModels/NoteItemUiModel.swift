//
//  NoteItemUiModel.swift
//  FlaxLabsNotes
//
//  Created by Drew Aquino on 10/18/23.
//

import Foundation
import Combine

public struct NoteItemUiModel {
  public let initial: Note
  public let publisher: AnyPublisher<Note, Exception>
  public init(initial: Note, publisher: AnyPublisher<Note, Exception>) {
    self.initial = initial
    self.publisher = publisher
  }
}
