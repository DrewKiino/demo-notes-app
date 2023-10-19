//
//  NotesListView.swift
//  FlaxLabsNotes
//
//  Created by Drew Aquino on 10/17/23.
//

import Foundation
import UIKit
import Combine
import SnapKit

public protocol NotesListViewDelegate: AnyObject {
  func notesListView(wantsToDelete noteId: String)
  func notesListView(wantsToEdit noteId: String)
}

public class NotesListView: UIView {
  
  private lazy var tableView: UITableView = {
    let view = UITableView(frame: .zero, style: .grouped)
    view.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    view.delegate = self
    view.dataSource = self
    return view
  }()
  
  private var uiModels: [NoteItemUiModel] = []
  
  public weak var delegate: NotesListViewDelegate?
  
  // cache for active observables
  private var cancellables: Set<AnyCancellable> = []

  public init() {
    super.init(frame: .zero)
    self.configureLayout()
  }
  
  public required init?(coder: NSCoder) {
    fatalError()
  }
  
  private func configureLayout() {
    self.backgroundColor = .white
    
    self.addSubview(self.tableView)
    
    self.tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  public func configure(uiModels: [NoteItemUiModel]) {
    // set local cache to new cache
    self.uiModels = uiModels
    // cancel and dealloc all previous observables
    self.cancellables.forEach { $0.cancel() }
    self.cancellables.removeAll()
    // reload data
    self.tableView.reloadData()
  }
  
  private func startObservingContentForNotePublisher(
    _ notePublisher: AnyPublisher<Note, Exception>,
    cell: UITableViewCell
  ) {
    cell.contentConfiguration = UIListContentConfiguration.sidebarSubtitleCell()
    let cancellable = notePublisher.sink { completion in
      switch completion {
      case .finished:
        break
      case let .failure(error):
        print(error)
      }
    } receiveValue: { [weak cell] note in
      if var content = cell?.contentConfiguration as? UIListContentConfiguration {
        content.text = note.title
        content.secondaryText = note.body
        cell?.contentConfiguration = content
      }
    }
    // insert cancellable to cache to dealloc later
    self.cancellables.insert(cancellable)
  }
}

extension NotesListView: UITableViewDelegate, UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    self.uiModels.count
  }
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
    // create and cache observer for note's content
    let notePublisher = self.uiModels[indexPath.row].publisher
    self.startObservingContentForNotePublisher(notePublisher, cell: cell)
    return cell
  }
  public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    true
  }
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.tableView.deselectRow(at: indexPath, animated: true)
    let note = self.uiModels[indexPath.row].initial
    self.delegate?.notesListView(wantsToEdit: note.noteId)
  }
  public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    let note = self.uiModels[indexPath.row].initial
    switch editingStyle {
    case .none: break
    case .delete: self.delegate?.notesListView(wantsToDelete: note.noteId)
    case .insert: break
    @unknown default: break
    }
  }
}
