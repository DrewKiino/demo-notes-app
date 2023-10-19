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
  case noData
  case invalidWire(Error)
}

public protocol FirebaseService {
  func configure()
  func fetchNoteSubject(for noteId: String) -> CurrentValueSubject<Note, Exception>?
  func insertNote(title: String, body: String) -> CurrentValueSubject<Note, Exception>
  func updateNote(noteId: String, title: String?, body: String?)
  func removeNote(noteId: String)
  func listNotes(callback: @escaping ([CurrentValueSubject<Note, Exception>]?, Exception?) -> ())
}

public class FirebaseServiceImpl: FirebaseService {
  
  private lazy var reference: DatabaseReference = Database.database().reference()
  
  private var handleByNoteId: [String: UInt] = [:]
  private var subjectByNoteId: [String: CurrentValueSubject<Note, Exception>] = [:]
  
  public init() {}
  
  public func configure() {
    FirebaseApp.configure()
    // quiet console for now
    FirebaseConfiguration.shared.setLoggerLevel(.min)
  }
  
  public func fetchNoteSubject(for noteId: String) -> CurrentValueSubject<Note, Exception>? {
    self.subjectByNoteId[noteId]
  }
  
  public func insertNote(title: String, body: String) -> CurrentValueSubject<Note, Exception> {
    // create random identifier for the note
    let noteId = UUID().uuidString
    // save data to remote
    self.reference.child("notes").child(noteId).setValue([
      "noteId": noteId,
      "title": title,
      "body": body,
      "createdAt": Date.now.millisecondsSince1970
    ] as [String : Any])
    // return the newly created note as an observable publisher
    let note = Note(noteId: noteId, title: title, body: body, createdAt: .now)
    return self.makeNotesReadObserver(for: note)
  }
  
  public func updateNote(noteId: String, title: String?, body: String?) {
    // update data to remote
    if let title = title {
      self.subjectByNoteId[noteId]?.value.title = title
      self.reference.child("notes/\(noteId)/title").setValue(title)
    }
    if let body = body {
      self.subjectByNoteId[noteId]?.value.body = body
      self.reference.child("notes/\(noteId)/body").setValue(body)
    }
  }
  
  public func removeNote(noteId: String) {
    // remove data at remote
    self.reference.child("notes").child(noteId).removeValue()
    // dealloc observer
    if let handle = self.handleByNoteId[noteId] {
      self.reference.removeObserver(withHandle: handle)
    }
  }
  
  public func listNotes(callback: @escaping ([CurrentValueSubject<Note, Exception>]?, Exception?) -> ()) {
    self.reference.child("notes").observeSingleEvent(of: .value) { [weak self] snapshot in
      guard let self = self else { return }
      do {
        let notes: [Note] = try snapshot.children.compactMap { child in
          if let snapshot = child as? DataSnapshot, let dictionary = snapshot.value as? NSDictionary {
            return try Note(dictionary: dictionary)
          }
          return nil
        }
        // remove the previous cache of observables
        for note in notes {
          if let handle = self.handleByNoteId[note.noteId] {
            self.reference.removeObserver(withHandle: handle)
          }
        }
        // recreate observables for each note
        let noteSubjects = notes.map { self.makeNotesReadObserver(for: $0) }
        callback(noteSubjects, nil)
      } catch let error {
        callback(nil, Exception(error))
      }
    }
  }
  
  private func makeNotesReadObserver(for note: Note) -> CurrentValueSubject<Note, Exception> {
    let subject = CurrentValueSubject<Note, Exception>(note)
    let noteId = note.noteId
    // start observer for firebase
    let handle = self.reference.child("notes/\(noteId)").observe(.childChanged) { snapshot in
      if snapshot.exists(), let value = snapshot.value as? NSDictionary {
        do {
          let note = try Note(dictionary: value)
          subject.send(note)
        } catch let error {
          subject.send(completion: .failure(Exception(FirebaseServiceError.invalidWire(error))))
        }
      }
    }
    // keep a reference of the handle so we can dealloc later
    self.handleByNoteId[noteId] = handle
    // keep a reference of the subject so we can do real time updates
    self.subjectByNoteId[noteId] = subject
    return subject
  }
}
