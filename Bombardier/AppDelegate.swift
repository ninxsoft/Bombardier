//
//  AppDelegate.swift
//  Bombardier
//
//  Created by Nindi Gill on 18/5/19.
//  Copyright © 2019 Nindi Gill. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  func applicationDidFinishLaunching(_ aNotification: Notification) {

    let key: String = "SoftwareUpdateCatalogURL"

    guard let string: String = UserDefaults.standard.object(forKey: key) as? String,
      !string.isEmpty else {
        let defaultString: String = "https://swscan.apple.com/content/catalogs/others/" +
      "index-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog"
      UserDefaults.standard.set(defaultString, forKey: key)
      return
    }
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
}
