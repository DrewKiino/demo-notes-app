//
//  AppDelegate.swift
//  FlaxLabsNotes
//
//  Created by Drew Aquino on 10/17/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  /// we use a resolver to manage our dependency graph in the app
  public let resolver = ResolverImpl()
  
  // MARK: Dependencies
  
  private lazy var firebaseService: FirebaseService = self.resolver.get()
  
  // MARK: UIApplication Lifecycle

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    self.firebaseService.configure()
    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }


}

