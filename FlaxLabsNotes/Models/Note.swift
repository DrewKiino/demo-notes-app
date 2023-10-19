//
//  Note.swift
//  FlaxLabsNotes
//
//  Created by Drew Aquino on 10/17/23.
//

import Foundation

public struct Note {
  
  public let noteId: String
  public var title: String
  public var body: String
  public let createdAt: Date
  
  public init(noteId: String, title: String, body: String, createdAt: Date) {
    self.noteId = noteId
    self.title = title
    self.body = body
    self.createdAt = createdAt
  }
  
  public init(dictionary: NSDictionary) throws {
    guard let noteId = dictionary["noteId"] as? String else {
      throw WireError.unableToMap(key: "noteId")
    }
    guard let title = dictionary["title"] as? String else {
      throw WireError.unableToMap(key: "title")
    }
    guard let body = dictionary["body"] as? String else {
      throw WireError.unableToMap(key: "body")
    }
    guard let createdAt = dictionary["createdAt"] as? Int else {
      throw WireError.unableToMap(key: "createdAt")
    }
    self.init(noteId: noteId, title: title, body: body, createdAt: Date(milliseconds: createdAt))
  }
}
