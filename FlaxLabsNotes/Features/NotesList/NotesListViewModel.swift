//
//  NotesListViewModel.swift
//  FlaxLabsNotes
//
//  Created by Drew Aquino on 10/17/23.
//

import Foundation
import Combine

public protocol NotesListViewModelDelegate: AnyObject {
  func notesListViewModel(didUpdateList viewModel: NotesListViewModel)
  func notesListViewModel(didReceiveError error: Exception)
}

public protocol NotesListViewModel {
  var uiModels: [NoteItemUiModel] { get }
  func noteSubject(for noteId: String) -> CurrentValueSubject<Note, Exception>?
  func addNote(title: String, body: String) -> CurrentValueSubject<Note, Exception> 
  func removeNote(noteId: String)
  func updateNote(noteId: String, title: String?, body: String?)
  func configure(delegate: NotesListViewModelDelegate)
}

public class NotesListViewModelImpl: NotesListViewModel {
  
  private let firebaseService: FirebaseService
  
  private weak var delegate: NotesListViewModelDelegate?
  
  private var noteSubjects: [CurrentValueSubject<Note, Exception>] = []
  
  // convert local cache of note subjects to ui models
  public var uiModels: [NoteItemUiModel] {
    self.noteSubjects.sorted(by: { lhs, rhs in
      lhs.value.createdAt > rhs.value.createdAt
    }).map { subject in
      NoteItemUiModel(initial: subject.value, publisher: subject.eraseToAnyPublisher())
    }
  }
  
  public init(resolver: Resolver) {
    self.firebaseService = resolver.get()
  }
  
  public func setDelegate(_ delegate: NotesListViewModelDelegate) {
    self.delegate = delegate
  }
  
  public func configure(delegate: NotesListViewModelDelegate) {
    self.delegate = delegate
    self.firebaseService.listNotes { [weak self] noteSubjects, error in
      guard let self = self else { return }
      if let error = error {
        self.delegate?.notesListViewModel(didReceiveError: error)
      } else if let noteSubjects = noteSubjects {
        self.noteSubjects = noteSubjects
        self.delegate?.notesListViewModel(didUpdateList: self)
      }
    }
  }
  
  public func noteSubject(for noteId: String) -> CurrentValueSubject<Note, Exception>? {
    self.firebaseService.fetchNoteSubject(for: noteId)
  }
  
  public func addNote(title: String, body: String) -> CurrentValueSubject<Note, Exception> {
    // insert to remote then receive observable note subject
    let noteSubject = self.firebaseService.insertNote(title: title, body: body)
    // add observable to cache
    self.noteSubjects.insert(noteSubject, at: 0)
    // publish new cache
    self.delegate?.notesListViewModel(didUpdateList: self)
    return noteSubject
  }
  
  public func updateNote(noteId: String, title: String?, body: String?) {
    self.firebaseService.updateNote(noteId: noteId, title: title, body: body)
  }
  
  public func removeNote(noteId: String) {
    // remove note from subjects
    self.noteSubjects = self.noteSubjects.filter { $0.value.noteId != noteId }
    // remove from remote
    self.firebaseService.removeNote(noteId: noteId)
    // publish new cache
    self.delegate?.notesListViewModel(didUpdateList: self)
  }
}
