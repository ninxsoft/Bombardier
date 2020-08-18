//
//  BombardierApp.swift
//  Bombardier
//
//  Created by Nindi Gill on 3/7/20.
//

import SwiftUI

@main
struct BombardierApp: App {
  // swiftlint:disable:next weak_delegate
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate
  @StateObject var preferences: Preferences = Preferences.shared

  @SceneBuilder var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(preferences)
    }
    .commands {
      AppCommands()
    }
    Settings {
      PreferencesView()
    }
  }
}
