//
//  MainViewController.swift
//  Bombardier
//
//  Created by Nindi Gill on 18/5/19.
//  Copyright © 2019 Nindi Gill. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

  enum OutlineViewType: Int {
    case macModels
    case bootCampPackages
  }

  static let downloadPath: String = NSHomeDirectory() + "/Downloads/Bombardier"
  private var macModels: MacModels = MacModels()
  private var filteredMacModels: [MacModel] = []
  private var bootCampPackages: BootCampPackages = BootCampPackages()
  private var filteredBootCampPackages: [BootCampPackage] = []
  private var type: OutlineViewType = .macModels
  @IBOutlet weak var searchField: NSSearchField?
  @IBOutlet weak var tabView: NSTabView?
  @IBOutlet weak var macModelsOutlineView: NSOutlineView?
  @IBOutlet weak var bootCampPackagesOutlineView: NSOutlineView?
  @IBOutlet weak var segmentedControl: NSSegmentedControl?

  override func viewWillAppear() {
   self.presentUpdateWindowController()
  }

  @IBAction func didClickPreferences(sender: NSMenuItem) {
    let storyboard: NSStoryboard = NSStoryboard(name: "Main", bundle: nil)
    let identifier: String = "PreferencesWindowController"

    guard let windowController: NSWindowController =  storyboard.instantiateController(withIdentifier: identifier) as?
     NSWindowController else {
      return
    }

    windowController.showWindow(self)
  }

  @IBAction func didClickToolbarSegmentedControl(sender: NSSegmentedControl) {
    tabView?.selectTabViewItem(at: sender.selectedSegment)

    if let outlineViewType: OutlineViewType = OutlineViewType(rawValue: sender.selectedSegment) {
      type = outlineViewType
    }

    switch type {
    case .macModels:
      self.macModelsOutlineView?.reloadData()
      self.macModelsOutlineView?.expandItem(nil, expandChildren: true)
    case .bootCampPackages:
      self.bootCampPackagesOutlineView?.reloadData()
      self.bootCampPackagesOutlineView?.expandItem(nil, expandChildren: true)
    }
  }

  @IBAction func didClickSegmentedControl(sender: NSSegmentedControl) {
    switch sender.selectedSegment {
    case 0:
      expandAll()
    case 1:
      collapseAll()
    case 3:
      self.presentUpdateWindowController()
    default:
      break
    }
  }

  @IBAction func didDoubleClickOutlineView(sender: NSOutlineView) {
    downloadPackage()
  }

  @IBAction func downloadButtonClicked(sender: NSButton) {
    downloadPackage()
  }

  @IBAction func showInFinderButtonClicked(sender: NSButton) {
    var path: String = ""

    switch type {
    case .macModels:
      // only action if selected row is a package (not a mac model)
      if let selectedRow: Int = self.macModelsOutlineView?.selectedRow,
        let package: BootCampPackage = self.macModelsOutlineView?.item(atRow: selectedRow) as? BootCampPackage {
        path = "\(MainViewController.downloadPath)/\(package.getName()).dmg"
      }
    case .bootCampPackages:
      // only action if selected row is a package (not a mac model)
      if let selectedRow: Int = self.bootCampPackagesOutlineView?.selectedRow,
        let package: BootCampPackage = self.bootCampPackagesOutlineView?.item(atRow: selectedRow) as? BootCampPackage {
        path = "\(MainViewController.downloadPath)/\(package.getName()).dmg"
      }
    }

    guard !path.isEmpty else {
      return
    }

    if FileManager.default.fileExists(atPath: path) {
      NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")
    }
  }

  // display the update sheet while downloading mac models and apple sus catalog plists are downloaded
  private func presentUpdateWindowController() {
    let storyboard: NSStoryboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    let identifier: String = "UpdateWindowController"

    guard let controller = storyboard.instantiateController(withIdentifier: identifier) as? NSWindowController else {
      return
    }

    self.view.window?.beginSheet((controller.window!), completionHandler: { _ in
      self.update()
    })
  }

  func downloadPackage() {
    var path: String = ""

    switch type {
    case .macModels:
      // only action if selected row is a package (not a mac model)
      if let selectedRow: Int = self.macModelsOutlineView?.selectedRow,
        let selectedPackage: BootCampPackage = self.macModelsOutlineView?.item(atRow: selectedRow) as? BootCampPackage {
        path = "\(MainViewController.downloadPath)/\(selectedPackage.getName()).dmg"

        if FileManager.default.fileExists(atPath: path) {
          NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")
        } else {
          self.presentDownloadWindowController(package: selectedPackage)
        }
      }
    case .bootCampPackages:
      // only action if selected row is a package (not a mac model)
      if let selectedRow: Int = self.bootCampPackagesOutlineView?.selectedRow,
        let selectedPackage: BootCampPackage =
        self.bootCampPackagesOutlineView?.item(atRow: selectedRow) as? BootCampPackage {
        path = "\(MainViewController.downloadPath)/\(selectedPackage.getName()).dmg"

        if FileManager.default.fileExists(atPath: path) {
          NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")
        } else {
          self.presentDownloadWindowController(package: selectedPackage)
        }
      }
    }
  }

  func updateMacModels() {
    self.macModels.update()
  }

  func updateBootCampPackages() {
    self.bootCampPackages.update()
  }

  private func update() {
    self.filteredMacModels = self.macModels.getModelArray()
    self.macModelsOutlineView?.reloadData()
    self.macModelsOutlineView?.expandItem(nil, expandChildren: true)
    self.filteredBootCampPackages = self.bootCampPackages.getPackageArray()
    self.bootCampPackagesOutlineView?.reloadData()
    self.bootCampPackagesOutlineView?.expandItem(nil, expandChildren: true)
    self.updateSegmentedControlLabel()
  }

  private func updateSegmentedControlLabel() {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    let modelsLastUpdated: String = dateFormatter.string(from: self.macModels.getLastUpdated())
    let packagesLastUpdated: String = dateFormatter.string(from: self.bootCampPackages.getLastUpdated())
    let string: String = "Mac Models: Updated \(modelsLastUpdated)" + "                         " +
                         "Software Update Catalog: Updated \(packagesLastUpdated)"
    self.segmentedControl?.setLabel(string, forSegment: 2)
  }

  private func expandAll() {
    switch type {
    case .macModels:
      macModelsOutlineView?.expandItem(nil, expandChildren: true)
    case .bootCampPackages:
      bootCampPackagesOutlineView?.expandItem(nil, expandChildren: true)
    }
  }

  private func collapseAll() {
    switch type {
    case .macModels:
      macModelsOutlineView?.collapseItem(nil, collapseChildren: true)
    case .bootCampPackages:
      bootCampPackagesOutlineView?.collapseItem(nil, collapseChildren: true)
    }
  }

  // display the download sheet while downloading and extracting the boot camp package
  private func presentDownloadWindowController(package: BootCampPackage) {
    let storyboard: NSStoryboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    let identifier: String = "DownloadWindowController"

    guard let controller = storyboard.instantiateController(withIdentifier: identifier) as? NSWindowController,
      let viewController = controller.contentViewController as? DownloadViewController else {
      return
    }

    viewController.package = package

    self.view.window?.beginSheet((controller.window!), completionHandler: { _ in
      self.update()
    })
  }
}

extension MainViewController: NSOutlineViewDataSource {

  func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    switch type {
    case .macModels:
      // total number of mac models
      guard let macModel: MacModel = item as? MacModel else {
        return self.filteredMacModels.count
      }

      // otherwise number of packages for the specific mac model
      let packages: [BootCampPackage] = self.bootCampPackages.getPackages(for: macModel.getModelIdentifier())
      return packages.count
    case .bootCampPackages:
      // total number of boot camp packages
      guard let package: BootCampPackage = item as? BootCampPackage else {
        return self.filteredBootCampPackages.count
      }

      // otherwise number of mac models for the specific boot camp package
      let models: [MacModel] = self.macModels.getModels(for: package.getModelIdentifiers())
      return models.count
    }
  }

  func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    switch type {
    case .macModels:
      // mac model
      guard let macModel: MacModel = item as? MacModel else {
        return self.filteredMacModels[index]
      }

      // otherwise package for mac model
      let packages: [BootCampPackage] = self.bootCampPackages.getPackages(for: macModel.getModelIdentifier())
      return packages[index]
    case .bootCampPackages:
      // boot camp package
      guard let package: BootCampPackage = item as? BootCampPackage else {
        return self.filteredBootCampPackages[index]
      }

      // otherwise mac model for package
      let models: [MacModel] = self.macModels.getModels(for: package.getModelIdentifiers())
      return models[index]
    }
  }

  func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    switch type {
    case .macModels:
      // only expandable if row is a mac model
      return item is MacModel
    case .bootCampPackages:
      // only expandable if row is a boot camp package
      return item is BootCampPackage
    }
  }
}

extension MainViewController: NSOutlineViewDelegate {

  func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {

    if let macModel: MacModel = item as? MacModel {

      guard let columnIdentifier: String = tableColumn?.identifier.rawValue,
        ["Model", "Identifier"].contains(columnIdentifier),
        let cell = outlineView.makeView(withIdentifier:
          NSUserInterfaceItemIdentifier(rawValue: "\(columnIdentifier)TableCellView"),
                                        owner: nil) as? NSTableCellView else {
        return nil
      }

      let isModelColumn: Bool = columnIdentifier == "Model"

      if isModelColumn,
        let image: NSImage = NSImage(contentsOfFile: macModel.getImagePath()) {
        cell.imageView?.image = image
      }

      cell.textField?.stringValue = isModelColumn ? macModel.getMarketingName() : macModel.getModelIdentifier()
      return cell
    }

    if let bootCampPackage: BootCampPackage = item as? BootCampPackage {

      guard let columnIdentifier: String = tableColumn?.identifier.rawValue,
        ["Package", "Updated", "Size"].contains(columnIdentifier),
        let cell = outlineView.makeView(withIdentifier:
          NSUserInterfaceItemIdentifier(rawValue: "\(columnIdentifier)TableCellView"),
                                        owner: nil) as? NSTableCellView else {
        return nil
      }

      switch columnIdentifier {
      case "Package":
        let path: String = "\(MainViewController.downloadPath)/\(bootCampPackage.getName()).dmg"
        let exists: Bool = FileManager.default.fileExists(atPath: path)
        let imagePath: String = exists ? BootCampPackages.downloadedImagePath : BootCampPackages.imagePath
        if let image: NSImage = NSImage(contentsOfFile: imagePath) {
          cell.imageView?.image = image
        }

        cell.textField?.stringValue = bootCampPackage.getName()
        return cell
      case "Updated":
        cell.textField?.stringValue = bootCampPackage.getDateString()
        return cell
      case "Size":
        cell.textField?.stringValue = bootCampPackage.getSizeString()
        return cell
      default:
        return nil
      }
    }

    return nil
  }
}

extension MainViewController: NSTextFieldDelegate {

  func controlTextDidChange(_ obj: Notification) {

    guard let object: NSSearchField = obj.object as? NSSearchField else {
      return
    }

    let searchString: String = object.stringValue.lowercased()

    // reset filtering if search string is empty
    guard !searchString.isEmpty else {
      self.filteredMacModels = self.macModels.getModelArray()
      self.macModelsOutlineView?.reloadData()
      self.macModelsOutlineView?.expandItem(nil, expandChildren: true)
      self.filteredBootCampPackages = self.bootCampPackages.getPackageArray()
      self.bootCampPackagesOutlineView?.reloadData()
      self.bootCampPackagesOutlineView?.expandItem(nil, expandChildren: true)
      return
    }

    switch type {
    case .macModels:
      filterMacModels(string: searchString)
    case .bootCampPackages:
      filterBootCampPackages(string: searchString)
    }
  }

  private func filterMacModels(string: String) {

    // start fresh
    self.filteredMacModels.removeAll()

    // add matches for model identifiers and marketing names
    for model in self.macModels.getModelArray() {

      let modelIdentifierMatch: Bool = model.getModelIdentifier().lowercased().contains(string)
      let marketingNameMatch: Bool = model.getMarketingName().lowercased().contains(string)

      if modelIdentifierMatch || marketingNameMatch {
        self.filteredMacModels.append(model)
      }
    }

    // add matches for boot camp package names, dates and size
    for package in self.bootCampPackages.getPackageArray() {

      let nameMatch: Bool = package.getName().lowercased().contains(string)
      let dateMatch: Bool = package.getDateString().lowercased().contains(string)
      let sizeMatch: Bool = package.getSizeString().lowercased().contains(string)

      if nameMatch || dateMatch || sizeMatch {

        for model in self.macModels.getModelArray() {

          let packageMatch: Bool = package.getModelIdentifiers().contains(model.getModelIdentifier())

          if packageMatch && !self.filteredMacModels.contains(model) {
            self.filteredMacModels.append(model)
          }
        }
      }
    }

    self.macModelsOutlineView?.reloadData()
    self.macModelsOutlineView?.expandItem(nil, expandChildren: true)
  }

  private func filterBootCampPackages(string: String) {

    // start fresh
    self.filteredBootCampPackages.removeAll()

    // add matches for boot camp package names, date and size
    for package in self.bootCampPackages.getPackageArray() {

      let nameMatch: Bool = package.getName().lowercased().contains(string)
      let dateMatch: Bool = package.getDateString().lowercased().contains(string)
      let sizeMatch: Bool = package.getSizeString().lowercased().contains(string)

      if nameMatch || dateMatch || sizeMatch {
        self.filteredBootCampPackages.append(package)
      }
    }

    // add matches for model identifiers and marketing names
    for model in self.macModels.getModelArray() {

      let modelIdentifierMatch: Bool = model.getModelIdentifier().lowercased().contains(string)
      let marketingNameMatch: Bool = model.getMarketingName().lowercased().contains(string)

      if modelIdentifierMatch || marketingNameMatch {
        let packages: [BootCampPackage] = self.bootCampPackages.getPackages(for: model.getModelIdentifier())

        for package in packages {
          if !self.filteredBootCampPackages.contains(package) {
            self.filteredBootCampPackages.append(package)
          }
        }
      }
    }

    self.bootCampPackagesOutlineView?.reloadData()
    self.bootCampPackagesOutlineView?.expandItem(nil, expandChildren: true)
  }
}
