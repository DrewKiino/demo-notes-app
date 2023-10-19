//
//  InteractiveModalPresenter.swift
//  FlaxLabsNotes
//
//  Created by Drew Aquino on 10/18/23.
//

import Foundation
import UIKit

/// The protocol allows a Child view send delegates it's parent (InteractiveModalPresenter) ie. manual dismiss
public protocol InteractiveModalPresenterChildViewDelegate: AnyObject {
  func interactiveModalViewControllerChild(wantsToDismiss view: UIView)
}

/// Child views of InteractiveModalPresenter need to conform to this protocol
public protocol InteractiveModalPresenterChildView: UIView {
  var interactiveModalPresenterChildViewDelegate: InteractiveModalPresenterChildViewDelegate? { get set }
}

public class InteractiveModalPresenter<T: UIView>: UIViewController, UISheetPresentationControllerDelegate {
  
  private lazy var notch: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    view.layer.cornerRadius = 5.0 / 2.0
    return view
  }()
  
  private lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.clipsToBounds = true
    view.layer.cornerRadius = 25.0
    view.layer.shadowOpacity = 1.0
    view.layer.shadowRadius = 15.0
    view.layer.shadowOffset = .init(width: 0.0, height: -5.0)
    view.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
    return view
  }()

  public let childView: T
  private let onPresent: (() -> ())?
  private let onDismiss: (() -> ())?
  
  public init(
    childView: T,
    detentHeight: CGFloat,
    onPresent: (() -> ())? = nil,
    onDismiss: (() -> ())? = nil
  ) {
    self.childView = childView
    self.onPresent = onPresent
    self.onDismiss = onDismiss
    super.init(nibName: nil, bundle: nil)
    
    // set child delegate to self if it conforms to it
    if let childView = childView as? InteractiveModalPresenterChildView {
      childView.interactiveModalPresenterChildViewDelegate = self
    }
    
    if let presentationController = presentationController as? UISheetPresentationController {
      if #available(iOS 16.0, *) { 
        presentationController.detents = [.custom(resolver: { context in detentHeight })]
      } else {
        presentationController.detents = [.medium()]
      }
      presentationController.delegate = self
    }
  }
  
  internal required init?(coder: NSCoder) {
    fatalError()
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .clear
    
    self.view.addSubview(self.containerView)
    self.view.addSubview(self.notch)
    self.view.addSubview(self.childView)

    self.containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.notch.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().offset(12.0)
      make.width.equalTo(51.0)
      make.height.equalTo(5.0)
    }
    
    self.childView.snp.makeConstraints { make in
      make.top.equalTo(self.notch.snp.bottom).offset(12.0)
      make.leading.trailing.bottom.equalToSuperview().inset(UIEdgeInsets(top: 0.0, left: 0.0, bottom: UIWindow.safeAreaInsets.bottom, right: 0.0))
    }
  }
  
  public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    self.onDismiss?()
  }
  
  public static func presentFrom<R: UIView>(
    _ presenter: UIViewController,
    withChildView childView: R,
    detentHeight: CGFloat,
    onPresent: (() -> ())? = nil,
    onDismiss: (() -> ())? = nil
  ) {
    let viewController = InteractiveModalPresenter<R>(
      childView: childView,
      detentHeight: detentHeight,
      onPresent: onPresent,
      onDismiss: onDismiss
    )
    presenter.present(viewController, animated: true, completion: onPresent)
  }
}

extension InteractiveModalPresenter: InteractiveModalPresenterChildViewDelegate {
  public func interactiveModalViewControllerChild(wantsToDismiss view: UIView) {
    self.dismiss(animated: true) { [weak self] in
      guard let self = self else { return }
      self.onDismiss?()
    }
  }
}
