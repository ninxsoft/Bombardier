//
//  BootCampPackages.swift
//  Bombardier
//
//  Created by Nindi Gill on 18/5/19.
//  Copyright © 2019 Nindi Gill. All rights reserved.
//

import Cocoa

class BootCampPackages: NSObject {

  static let remotePath = "https://swscan.apple.com/content/catalogs/others/" +
  "index-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog"
  static let directoryPath = NSHomeDirectory() + "/Library/Application Support/Bombardier"
  static let localPath = NSHomeDirectory() + "/Library/Application Support/Bombardier/SUCatalog.plist"
  static let imagePath = "/System/Library/CoreServices/DiskImageMounter.app/Contents/Resources/diskcopy-doc.icns"
  private var packageArray = [BootCampPackage]()
  private var lastUpdated = Date()

  func update() {
    self.downloadUpdate()
  }

  private func downloadUpdate() {

    var isDirectory = ObjCBool(false)
    // create the download directory if required
    if !FileManager.default.fileExists(atPath: BootCampPackages.directoryPath, isDirectory: &isDirectory) {
      do {
        try FileManager.default.createDirectory(atPath: BootCampPackages.directoryPath,
                                                withIntermediateDirectories: false,
                                                attributes: nil)
      } catch let error {
        print(error)
      }
    }

    guard let url = URL(string: BootCampPackages.remotePath) else {
      self.updateVariables(success: false)
      return
    }

    let task = URLSession.shared.downloadTask(with: url) { tempURL, _, _ in

      guard let tempURL = tempURL,
        let dictionary = NSDictionary(contentsOf: tempURL) else {
          self.updateVariables(success: false)
          return
      }

      // if all is well, write the BootCampPackages.plist to local disk
      let success = dictionary.write(toFile: BootCampPackages.localPath, atomically: true)
      self.updateVariables(success: success)
    }

    task.resume()
  }

  func updateVariables(success: Bool) {

    var dictionary = NSDictionary()

    if let dict =  NSDictionary(contentsOfFile: BootCampPackages.localPath) {
      dictionary = dict
    }

    if let products = dictionary.object(forKey: "Products") as? NSDictionary {

      self.packageArray.removeAll()

      for (key, product) in products {

        if let productDictionary = product as? NSDictionary,
          let serverMetadataURL = productDictionary.object(forKey: "ServerMetadataURL") as? String,
          serverMetadataURL.contains("BootCamp"),
          let name = key as? String,
          let date = productDictionary.object(forKey: "PostDate") as? Date,
          let packages = productDictionary.object(forKey: "Packages") as? NSArray,
          let packageDictionary = packages.firstObject as? NSDictionary,
          let size = packageDictionary.object(forKey: "Size") as? Int,
          let url = packageDictionary.object(forKey: "URL") as? String,
          let distributions = productDictionary.object(forKey: "Distributions") as? NSDictionary,
          let distributionURL = distributions.object(forKey: "English") as? String {
          let modelIdentifiers = self.modelIdentifiers(from: distributionURL)
          let bootCampPackage = BootCampPackage(name: name,
                                                size: size,
                                                date: date,
                                                url: url,
                                                modelIdentifiers: modelIdentifiers)
          self.packageArray.append(bootCampPackage)
        }
      }
    }

    if let lastUpdated = dictionary.object(forKey: "IndexDate") as? Date {
      self.lastUpdated = lastUpdated
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      let name = NSNotification.Name(rawValue: "BootCampPackagesUpdateComplete")
      NotificationCenter.default.post(name: name, object: success)
    }
  }

  func getPackageArray() -> [BootCampPackage] {
    return self.packageArray
  }

  func getLastUpdated() -> Date {
    return self.lastUpdated
  }

  // each package has a distribution url, determine the corresponding model identifiers from said distribution url
  private func modelIdentifiers(from distributionURL: String) -> [String] {

    var modelIdentifiers = [String]()
    let seperator = "*"

    guard let url = URL(string: distributionURL) else {
      return modelIdentifiers
    }

    do {
      let contents = try String(contentsOf: url)
      var string = contents

      if let startIndex = string.range(of: "var models = [", options: [])?.upperBound {
        var substring = string[startIndex...]
        string = String(substring)

        if let endIndex = string.range(of: ",];", options: [])?.lowerBound {
          substring = string[..<endIndex]
          string = String(substring)
          string = string.replacingOccurrences(of: "','", with: "'\(seperator)'")
          string = string.replacingOccurrences(of: "'", with: "")

          modelIdentifiers = string.components(separatedBy: seperator)
        }
      }

    } catch let error {
      print(error)
    }

    return modelIdentifiers
  }

  // grab a list of packages (sorted from newest to oldest) for a particular model identifier
  func getPackages(for modelIdentifier: String) -> [BootCampPackage] {

    var packages = [BootCampPackage]()

    for package in self.packageArray {

      if package.getModelIdentifiers().contains(modelIdentifier) {
        packages.append(package)
      }
    }

    packages.sort { $0.getDate() > $1.getDate() }
    return packages
  }

  override var description: String {

    var string = "Last Updated: \(self.lastUpdated)\n"

    for package in self.packageArray {
      string.append("\n\(package.description)")
    }

    return string
  }
}
