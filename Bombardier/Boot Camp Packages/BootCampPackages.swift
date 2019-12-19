//
//  BootCampPackages.swift
//  Bombardier
//
//  Created by Nindi Gill on 18/5/19.
//  Copyright © 2019 Nindi Gill. All rights reserved.
//

import Cocoa

class BootCampPackages: NSObject {
  static let directoryPath: String = NSHomeDirectory() + "/Library/Application Support/Bombardier"
  static let localPath: String = NSHomeDirectory() + "/Library/Application Support/Bombardier/SUCatalog.plist"
  static let imagePath: String =
  "/System/Library/CoreServices/Install Command Line Developer Tools.app/Contents/Resources/SoftwareUpdate.icns"
  static let downloadedImagePath: String =
  "/System/Library/CoreServices/DiskImageMounter.app/Contents/Resources/diskcopy-doc.icns"
  private var packageArray: [BootCampPackage] = []
  private var lastUpdated: Date = Date()

  // each package has a distribution url, determine the corresponding model identifiers from said distribution url
  private func modelIdentifiers(from distributionURL: String) -> [String] {

    var modelIdentifiers: [String] = []
    let seperator: String = "*"

    guard let url = URL(string: distributionURL) else {
      return modelIdentifiers
    }

    do {
      let contents: String = try String(contentsOf: url)
      var string: String = contents

      if let startIndex: String.Index = string.range(of: "var models = [", options: [])?.upperBound {
        var substring: Substring = string[startIndex...]
        string = String(substring)

        if let endIndex: String.Index = string.range(of: ",];", options: [])?.lowerBound {
          substring = string[..<endIndex]
          string = String(substring)
          string = string.replacingOccurrences(of: "','", with: "'\(seperator)'")
          string = string.replacingOccurrences(of: "'", with: "")

          modelIdentifiers = string.components(separatedBy: seperator)
        }
      }

    } catch {
      print(error)
    }

    return modelIdentifiers
  }

  func update() {
    self.downloadUpdate()
  }

  private func downloadUpdate() {

    var isDirectory: ObjCBool = ObjCBool(false)
    // create the download directory if required
    if !FileManager.default.fileExists(atPath: BootCampPackages.directoryPath, isDirectory: &isDirectory) {
      do {
        try FileManager.default.createDirectory(atPath: BootCampPackages.directoryPath,
                                                withIntermediateDirectories: false,
                                                attributes: nil)
      } catch {
        print(error)
      }
    }

    let key: String = "SoftwareUpdateCatalogURL"

    guard let string: String = UserDefaults.standard.object(forKey: key) as? String,
      let url = URL(string: string) else {
      self.updateVariables(success: false)
      return
    }

    let task: URLSessionDownloadTask = URLSession.shared.downloadTask(with: url) { tempURL, _, _ in

      guard let tempURL = tempURL,
        let dictionary = NSDictionary(contentsOf: tempURL) else {
          self.updateVariables(success: false)
          return
      }

      // if all is well, write the BootCampPackages.plist to local disk
      let success: Bool = dictionary.write(toFile: BootCampPackages.localPath, atomically: true)
      self.updateVariables(success: success)
    }

    task.resume()
  }

  func updateVariables(success: Bool) {

    var dictionary: NSDictionary = NSDictionary()

    if let dict: NSDictionary = NSDictionary(contentsOfFile: BootCampPackages.localPath) {
      dictionary = dict
    }

    if let products: [String: Any] = dictionary.object(forKey: "Products") as? [String: Any] {

      self.packageArray.removeAll()

      for (key, product) in products {

        if let productDictionary: [String: Any] = product as? [String: Any],
          let serverMetadataURL: String = productDictionary["ServerMetadataURL"] as? String,
          serverMetadataURL.contains("BootCamp"),
          let date: Date = productDictionary["PostDate"] as? Date,
          let packages: [Any] = productDictionary["Packages"] as? [Any],
          let packageDictionary: [String: Any] = packages.first as? [String: Any],
          let size: Int = packageDictionary["Size"] as? Int,
          let url: String = packageDictionary["URL"] as? String,
          let distributions: [String: Any] = productDictionary["Distributions"] as? [String: Any],
          let distributionURL: String = distributions["English"] as? String {
          let modelIdentifiers: [String] = self.modelIdentifiers(from: distributionURL)
          let bootCampPackage: BootCampPackage = BootCampPackage(name: key,
                                                size: size,
                                                date: date,
                                                url: url,
                                                modelIdentifiers: modelIdentifiers)
          self.packageArray.append(bootCampPackage)
        }
      }
    }

    if let lastUpdated: Date = dictionary.object(forKey: "IndexDate") as? Date {
      self.lastUpdated = lastUpdated
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      let name: NSNotification.Name = NSNotification.Name(rawValue: "BootCampPackagesUpdateComplete")
      NotificationCenter.default.post(name: name, object: success)
    }
  }

  func getPackageArray() -> [BootCampPackage] {
    return self.packageArray
  }

  func getLastUpdated() -> Date {
    return self.lastUpdated
  }

  // grab a list of packages (sorted from newest to oldest) for a particular model identifier
  func getPackages(for modelIdentifier: String) -> [BootCampPackage] {

    var packages: [BootCampPackage] = []

    for package in self.packageArray {

      if package.getModelIdentifiers().contains(modelIdentifier) {
        packages.append(package)
      }
    }

    packages.sort { $0.getDate() > $1.getDate() }
    return packages
  }
}
