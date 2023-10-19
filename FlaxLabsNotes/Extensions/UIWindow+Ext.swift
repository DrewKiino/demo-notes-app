//
//  UIWindow+Ext.swift
//  FlaxLabsNotes
//
//  Created by Drew Aquino on 10/18/23.
//

import Foundation
import UIKit

extension UIWindow {
  public static var safeAreaInsets: UIEdgeInsets {
    let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    return scene?.windows.first?.safeAreaInsets ?? .zero
  }
}
