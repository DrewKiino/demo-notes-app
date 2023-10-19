//
//  NotesListViewController.swift
//  FlaxLabsNotes
//
//  Created by Drew Aquino on 10/17/23.
//

import Foundation
import UIKit

public class NotesListViewController: UIViewController {
  
  private let _view: NotesListView
  private let viewModel: NotesListViewModel
  
  public init(viewModel: NotesListViewModel) {
    self._view = NotesListView()
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  public required init?(coder: NSCoder) {
    fatalError()
  }
  
  public override func loadView() {
    // use our own view as the backing layer for this view controller
    self.view = self._view
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    self.configureSelf()
    
    self.viewModel.configure(delegate: self)
    self._view.delegate = self
  }
  
  private func configureSelf() {
    self.title = "FlaxLabs Notes App"
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onTapAdd))
  }
  
  @objc private func onTapAdd() {
    let subject = self.viewModel.addNote(title: "", body: "")
    let childView = EditNoteModalView(subject: subject)
    childView.delegate = self
    InteractiveModalPresenter.presentFrom(
      self,
      withChildView: childView,
      detentHeight: UIScreen.main.bounds.height / 3.0
    )
  }
}

extension NotesListViewController: NotesListViewModelDelegate {
  public func notesListViewModel(didUpdateList viewModel: NotesListViewModel) {
    self._view.configure(uiModels: viewModel.uiModels)
  }
  
  public func notesListViewModel(didReceiveError error: Exception) {
    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OKAY", style: .destructive, handler: { _ in }))
    self.present(alert, animated: true)
  }
}

extension NotesListViewController: NotesListViewDelegate {
  public func notesListView(wantsToEdit noteId: String) {
    guard let subject = self.viewModel.noteSubject(for: noteId) else { return }
    let childView = EditNoteModalView(subject: subject)
    childView.delegate = self
    InteractiveModalPresenter.presentFrom(
      self,
      withChildView: childView,
      detentHeight: UIScreen.main.bounds.height / 3.0
    )
  }
  public func notesListView(wantsToDelete noteId: String) {
    self.viewModel.removeNote(noteId: noteId)
  }
}

extension NotesListViewController: EditNoteModalViewDelegate {
  public func editNoteModalView(didChangeTitle noteId: String, title: String) {
    self.viewModel.updateNote(noteId: noteId, title: title, body: nil)
  }
  public func editNoteModalView(didChangeBody noteId: String, body: String) {
    self.viewModel.updateNote(noteId: noteId, title: nil, body: body)
  }
}

