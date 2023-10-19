//
//  EditNoteModalView.swift
//  FlaxLabsNotes
//
//  Created by Drew Aquino on 10/18/23.
//

import Foundation
import UIKit
import SnapKit
import Combine

public protocol EditNoteModalViewDelegate: AnyObject {
  func editNoteModalView(didChangeTitle noteId: String, title: String)
  func editNoteModalView(didChangeBody noteId: String, body: String)
}

public class EditNoteModalView: UIView, InteractiveModalPresenterChildView {
  private let subject: CurrentValueSubject<Note, Exception>
  
  private lazy var titleField: UITextView = {
    let view = UITextView()
    view.isScrollEnabled = false
    view.delegate = self
    view.backgroundColor = UIColor.black.withAlphaComponent(0.05)
    view.layer.cornerRadius = 8.0
    view.font = UIFont.systemFont(ofSize: 24.0, weight: .bold)
    view.textColor = .black
    view.textAlignment = .center
    view.textContainerInset = UIEdgeInsets(top: 16.0, left: 8.0, bottom: 16.0, right: 8.0)
    view.autocorrectionType = .no
    view.spellCheckingType = .no
    return view
  }()
  
  private lazy var bodyField: UITextView = {
    let view = UITextView()
    view.isScrollEnabled = true
    view.delegate = self
    view.backgroundColor = UIColor.black.withAlphaComponent(0.05)
    view.layer.cornerRadius = 8.0
    view.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
    view.textColor = .black
    view.textContainerInset = UIEdgeInsets(top: 16.0, left: 8.0, bottom: 16.0, right: 8.0)
    view.autocorrectionType = .no
    view.spellCheckingType = .no
    return view
  }()
  
  private lazy var doneButton: UIButton = {
    let view = UIButton(configuration: {
      var config = UIButton.Configuration.plain()
      config.attributedTitle = AttributedString(
        "DONE",
        attributes: .init([
          .font: UIFont.systemFont(ofSize: 20.0, weight: .bold),
          .foregroundColor: UIColor.white
        ])
      )
      config.background.backgroundColor = .systemBlue
      return config
    }())
    view.addTarget(self, action: #selector(onTapDone(_:)), for: .touchUpInside)
    return view
  }()
  
  private var cancellable: AnyCancellable?
  
  public weak var delegate: EditNoteModalViewDelegate?
  public var interactiveModalPresenterChildViewDelegate: InteractiveModalPresenterChildViewDelegate?
  
  public init(subject: CurrentValueSubject<Note, Exception>) {
    self.subject = subject
    super.init(frame: .zero)
    self.configureSelf()
    self.configureLayout()
    
    self.cancellable = self.subject.sink(receiveCompletion: { _ in }) { [weak self] note in
      guard let self = self else { return }
      self.configure(note)
    }
  }
  
  public required init?(coder: NSCoder) {
    fatalError()
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    self.becomeFirstResponder()
  }
  
  @discardableResult
  public override func becomeFirstResponder() -> Bool {
    if self.titleField.isFirstResponder || self.bodyField.isFirstResponder {
      return true
    }
    if self.subject.value.title.isEmpty {
      return self.titleField.becomeFirstResponder()
    } else {
      return self.bodyField.becomeFirstResponder()
    }
  }
  
  private func configureSelf() {
    self.backgroundColor = .systemBackground
  }
  
  private func configureLayout() {
    let contentInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 100.0, right: 16.0)
    self.addSubview(self.titleField)
    self.addSubview(self.bodyField)
    self.addSubview(self.doneButton)
    
    self.titleField.snp.makeConstraints { make in
      make.leading.top.trailing.equalToSuperview().inset(contentInset)
      make.height.equalTo(60.0)
    }
    
    self.bodyField.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(contentInset)
      make.top.equalTo(self.titleField.snp.bottom).offset(16.0)
      make.height.equalTo(138.0)
    }
    
    self.doneButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(contentInset)
      make.top.equalTo(self.bodyField.snp.bottom).offset(16.0)
      make.height.equalTo(44.0)
    }
  }
  
  public func configure(_ note: Note) {
    self.titleField.text = note.title
    self.bodyField.text = note.body
  }
  
  @objc private func onTapDone(_ button: UIButton) {
    self.interactiveModalPresenterChildViewDelegate?.interactiveModalViewControllerChild(wantsToDismiss: self)
  }
}

extension EditNoteModalView: UITextViewDelegate {
  public func textViewDidChange(_ textView: UITextView) {
    if textView == self.titleField {
      self.delegate?.editNoteModalView(didChangeTitle: self.subject.value.noteId, title: textView.text)
    } else if textView == self.bodyField {
      self.delegate?.editNoteModalView(didChangeBody: self.subject.value.noteId, body: textView.text)
    }
  }
}
