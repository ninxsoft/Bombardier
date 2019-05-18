//
//  MainViewController.swift
//  Bombardier
//
//  Created by Nindi Gill on 18/5/19.
//  Copyright © 2019 Nindi Gill. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

  static let downloadPath = NSHomeDirectory() + "/Downloads/Bombardier"
  static let downloadViewRect = NSRect(x: 0.0, y: 0.0, width: 64.0, height: 32.0)
  @IBOutlet var outlineView: NSOutlineView?
  @IBOutlet var searchField: NSSearchField?
  @IBOutlet var segmentedControl: NSSegmentedControl?
  private var macModels = MacModels()
  private var filteredMacModels = [MacModel]()
  private var bootCampPackages = BootCampPackages()
  private var downloadImage = DownloadView(frame: MainViewController.downloadViewRect).imageRepresentation()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear() {
   self.presentUpdateWindowController()
  }
  
  // display the update sheet while downloading mac models and apple sus catalog plists are downloaded
  private func presentUpdateWindowController() {
    
    let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    
    guard let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("UpdateWindowController")) as? NSWindowController else {
      return
    }
    
    self.view.window?.beginSheet((windowController.window!), completionHandler: { response in
      self.update()
    })
  }
  
  func updateMacModels() {
    self.macModels.update()
  }
  
  func updateBootCampPackages() {
    self.bootCampPackages.update()
  }
  
  private func update() {
    self.filteredMacModels = self.macModels.getModelArray()
    self.outlineView?.reloadData()
    self.outlineView?.expandItem(nil, expandChildren: true)
    self.updateOutlineViewColumnTitle()
    self.updateSegmentedControlLabel()
  }
  
  private func updateOutlineViewColumnTitle() {
    let lastUpdated = self.macModels.getLastUpdated()
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    let title = "Mac Models - Updated \(dateFormatter.string(from: lastUpdated))"
    self.outlineView?.outlineTableColumn?.title = title
  }
  
  private func updateSegmentedControlLabel() {
    let lastUpdated = self.bootCampPackages.getLastUpdated()
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    let title = "Software Update Catalog - Updated \(dateFormatter.string(from: lastUpdated))"
    self.segmentedControl?.setLabel(title, forSegment: 0)
  }
  
  @IBAction func segmentedControlClicked(sender: NSSegmentedControl) {
    
    guard sender.indexOfSelectedItem == sender.segmentCount - 1 else {
      return
    }
    
    // only action if the last segment is clicked
    self.presentUpdateWindowController()
  }
  
  @IBAction func outlineViewDoubleClicked(sender: NSOutlineView) {
    
    let selectedRow = sender.selectedRow
    
    // only action if selected row is a package (not a mac model)
    guard let package = sender.item(atRow: selectedRow) as? BootCampPackage,
      let tableCellView = sender.view(atColumn: 0, row: selectedRow, makeIfNecessary: false) as? BootCampPackageTableCellView,
      let downloadButton = tableCellView.downloadButton else {
        return
    }
    
    if downloadButton.title == "GET" {
      self.presentDownloadWindowController(package: package)
    } else if downloadButton.title == "OPEN" {
      let path = "\(MainViewController.downloadPath)/\(package.getName()).dmg"
      NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")
    }
  }
  
  @IBAction func downloadButtonClicked(sender: NSButton) {
    
    // only action if selected row is a package (not a mac model)
    guard let superview = sender.superview as? BootCampPackageTableCellView,
      let selectedRow = self.outlineView?.row(for: superview),
      let package = self.outlineView?.item(atRow: selectedRow) as? BootCampPackage else {
        return
    }
      
    if sender.title == "GET" {
      self.presentDownloadWindowController(package: package)
    } else if sender.title == "OPEN" {
      let path = "\(MainViewController.downloadPath)/\(package.getName()).dmg"
      NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")
    }
  }
  
  // display the download sheet while downloading and extracting the boot camp package
  private func presentDownloadWindowController(package: BootCampPackage) {
    
    let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    
    guard let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("DownloadWindowController")) as? NSWindowController else {
      return
    }
    
    guard let viewController = windowController.contentViewController as? DownloadViewController else {
      return
    }
    
    viewController.package = package
    
    self.view.window?.beginSheet((windowController.window!), completionHandler: { response in
      self.update()
    })
  }
}

extension MainViewController: NSOutlineViewDataSource {

  func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {

    // total number of mac models
    guard let macModel = item as? MacModel else {
      return self.filteredMacModels.count
    }
    
    // otherwise number of packages for the specific mac model
    let packages = self.bootCampPackages.getPackages(for: macModel.getModelIdentifier())
    return packages.count
  }

  func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {

    // mac model
    guard let macModel = item as? MacModel else {
      return self.filteredMacModels[index]
    }

    // otherwise package for mac model
    let packages = self.bootCampPackages.getPackages(for: macModel.getModelIdentifier())
    return packages[index]
  }

  func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    // only expandable if row is a mac model
    return item is MacModel
  }
}

extension MainViewController: NSOutlineViewDelegate {

  func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {

    if let macModel = item as? MacModel {

      guard let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MacModelTableCellView"), owner: nil) as? MacModelTableCellView else {
        return nil
      }

      cell.textField?.stringValue = macModel.getMarketingName()
      cell.modelIdentifierTextField?.stringValue = macModel.getModelIdentifier()
      
      if let image = NSImage(contentsOfFile: macModel.getImagePath()) {
        cell.imageView?.image = image
      } else {
        print("Unable to load image for \(macModel.getImagePath())!")
      }
      
      return cell
    }
    
    if let bootCampPackage = item as? BootCampPackage {
      
      guard let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "BootCampPackageTableCellView"), owner: nil) as? BootCampPackageTableCellView else {
        return nil
      }
      
      cell.downloadButton?.image = self.downloadImage
      
      let path = "\(MainViewController.downloadPath)/\(bootCampPackage.getName()).dmg"
      
      if FileManager.default.fileExists(atPath: path) {
        cell.downloadButton?.title = "OPEN"
      } else {
        cell.downloadButton?.title = "GET"
      }
      
      cell.textField?.stringValue = bootCampPackage.getName()
      
      if let image = NSImage(contentsOfFile: BootCampPackages.imagePath) {
        cell.imageView?.image = image
      } else {
        print("Unable to load image for \(BootCampPackages.imagePath)!")
      }
      
      let size = Float(bootCampPackage.getSize()) / 1000 / 1000
      cell.sizeTextField?.stringValue = String(format: "%.1f MB", size)

      let date = bootCampPackage.getDate()
      let dateFormatter = DateFormatter()
      dateFormatter.dateStyle = .short
      dateFormatter.timeStyle = .short
      cell.dateTextField?.stringValue = " - Updated \(dateFormatter.string(from: date))"

      return cell
    }

    return nil
  }
}

extension MainViewController: NSTextFieldDelegate {
  
  func controlTextDidChange(_ obj: Notification) {
    
    guard let object = obj.object as? NSSearchField else {
      return
    }
      
    let searchString = object.stringValue.lowercased()
    
    // reset filtering if search string is empty
    guard !searchString.isEmpty else {
      self.filteredMacModels = self.macModels.getModelArray()
      self.outlineView?.reloadData()
      self.outlineView?.expandItem(nil, expandChildren: true)
      return
    }
    
    // start fresh
    self.filteredMacModels.removeAll()
    
    // add matches for model identifiers and marketing names
    for model in self.macModels.getModelArray() {
      
      if model.getModelIdentifier().lowercased().contains(searchString) || model.getMarketingName().lowercased().contains(searchString) {
        self.filteredMacModels.append(model)
      }
    }
    
    // add matches for boot camp package names
    for package in self.bootCampPackages.getPackageArray() {

      if package.getName().lowercased().contains(searchString) {
    
        for model in self.macModels.getModelArray() {
          
          if package.getModelIdentifiers().contains(model.getModelIdentifier()) && !self.filteredMacModels.contains(model) {
            self.filteredMacModels.append(model)
          }
        }
      }
    }
    
    self.outlineView?.reloadData()
    self.outlineView?.expandItem(nil, expandChildren: true)
  }
}
