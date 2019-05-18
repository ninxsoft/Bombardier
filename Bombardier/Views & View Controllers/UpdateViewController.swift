//
//  UpdateViewController.swift
//  Bombardier
//
//  Created by Nindi Gill on 18/5/19.
//  Copyright © 2019 Nindi Gill. All rights reserved.
//

import Cocoa

class UpdateViewController: NSViewController {
  
  let macModelsUpdateComplete = NSNotification.Name(rawValue: "MacModelsUpdateComplete")
  let bootCampPackagesUpdateComplete = NSNotification.Name(rawValue: "BootCampPackagesUpdateComplete")
  @IBOutlet var textField: NSTextField?
  @IBOutlet var progressIndicator: NSProgressIndicator?
  @IBOutlet var button: NSButton?
  
  override func viewWillAppear() {
    NotificationCenter.default.addObserver(self, selector: #selector(macModelsUpdateComplete(notification:)), name: macModelsUpdateComplete, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(bootCampPackagesUpdateComplete(notification:)), name: bootCampPackagesUpdateComplete, object: nil)
    self.update()
  }
  
  private func update() {
    
    guard let mainViewController = self.view.window?.sheetParent?.contentViewController as? MainViewController else {
      self.updateFailed()
      return
    }
    
    DispatchQueue.main.async {
      self.progressIndicator?.startAnimation(self)
      self.textField?.stringValue = "Updating: Mac Models..."
    }
    
    let queue = DispatchQueue(label: "work")
    queue.async {
      mainViewController.updateMacModels()
    }
  }
  
  // called once the mac models have been downloaded and updated
  @objc func macModelsUpdateComplete(notification: NSNotification) {
    
    DispatchQueue.main.async {
      
      guard let mainViewController = self.view.window?.sheetParent?.contentViewController as? MainViewController,
        let success = notification.object as? Bool,
          success else {
        self.updateFailed()
        return
      }

      self.textField?.stringValue = "Updating: Boot Camp Packages..."
      
      let queue = DispatchQueue(label: "work")
      queue.async {
        mainViewController.updateBootCampPackages()
      }
    }
  }
  
  // called once the boot camp packages have been downloaded and updated
  @objc func bootCampPackagesUpdateComplete(notification: NSNotification) {

    DispatchQueue.main.async {
      
      guard let success = notification.object as? Bool,
        success else {
        self.updateFailed()
        return
      }
      
      self.textField?.stringValue = "Updating: Complete!"
      self.button?.title = "Close"
      self.progressIndicator?.stopAnimation(self)
      
      // end the sheet automatically if the update was successful
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.view.window?.sheetParent?.endSheet(self.view.window!, returnCode: .OK)
      }
    }
  }
  
  private func updateFailed() {
    
    DispatchQueue.main.async {
      self.textField?.stringValue = "Updating: Failed!"
      self.button?.title = "Close"
      self.progressIndicator?.stopAnimation(self)
    }
  }
  
  @IBAction func buttonClicked(sender: NSButton) {
    self.view.window?.sheetParent?.endSheet(self.view.window!, returnCode: .OK)
  }
}
