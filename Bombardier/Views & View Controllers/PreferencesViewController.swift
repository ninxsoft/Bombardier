//
//  PreferencesViewController.swift
//  Bombardier
//
//  Created by Nindi Gill on 19/12/19.
//  Copyright © 2019 Nindi Gill. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
  @IBOutlet weak var textField: NSTextField?

  override func viewDidAppear() {

    let key: String = "SoftwareUpdateCatalogURL"

    guard let string: String = UserDefaults.standard.object(forKey: key) as? String else {
      return
    }

    textField?.stringValue = string
  }
}

extension PreferencesViewController: NSTextFieldDelegate {

  func controlTextDidChange(_ obj: Notification) {

    guard let string: String = textField?.stringValue else {
      return
    }

    UserDefaults.standard.set(string, forKey: "SoftwareUpdateCatalogURL")
  }
}
