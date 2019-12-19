//
//  MacModels.swift
//  Bombardier
//
//  Created by Nindi Gill on 18/5/19.
//  Copyright © 2019 Nindi Gill. All rights reserved.
//

import Cocoa

class MacModels: NSObject {
  static let remotePath: String = "https://raw.githubusercontent.com/ninxsoft/Bombardier/master/MacModels.plist"
  static let directoryPath: String = NSHomeDirectory() + "/Library/Application Support/Bombardier"
  static let localPath: String = NSHomeDirectory() + "/Library/Application Support/Bombardier/MacModels.plist"
  private var modelArray: [MacModel] = []
  private var lastUpdated: Date = Date()

  func update() {
    self.downloadUpdate()
  }

  private func updateVariables(success: Bool) {

    var dictionary: NSDictionary = NSDictionary()

    if let dict: NSDictionary = NSDictionary(contentsOfFile: MacModels.localPath) {
      dictionary = dict
    }

    if let models: [Any] = dictionary.object(forKey: "Models") as? [Any] {

      self.modelArray.removeAll()

      for model in models {

        if let modelDictionary: [String: Any] = model as? [String: Any],
          let modelIdentifier: String = modelDictionary["ModelIdentifier"] as? String,
          let marketingName: String = modelDictionary["MarketingName"] as? String,
          let imagePath: String = modelDictionary["ImagePath"] as? String {
          let macModel: MacModel =
            MacModel(modelIdentifier: modelIdentifier, marketingName: marketingName, imagePath: imagePath)
          self.modelArray.append(macModel)
        }
      }
    }

    if let lastUpdated: Date = dictionary.object(forKey: "LastUpdated") as? Date {
      self.lastUpdated = lastUpdated
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      let name: NSNotification.Name = NSNotification.Name(rawValue: "MacModelsUpdateComplete")
      NotificationCenter.default.post(name: name, object: success)
    }
  }

  private func downloadUpdate() {

    var isDirectory: ObjCBool = ObjCBool(false)
    // create the download directory if required
    if !FileManager.default.fileExists(atPath: MacModels.directoryPath, isDirectory: &isDirectory) {
      do {
        try FileManager.default.createDirectory(atPath: MacModels.directoryPath,
                                                withIntermediateDirectories: false,
                                                attributes: nil)
      } catch {
        print(error)
      }
    }

    guard let url = URL(string: MacModels.remotePath) else {
      self.updateVariables(success: false)
      return
    }

    let task: URLSessionDownloadTask = URLSession.shared.downloadTask(with: url) { tempURL, _, _ in

      guard let tempURL = tempURL,
        let dictionary = NSDictionary(contentsOf: tempURL) else {
          self.updateVariables(success: false)
          return
      }

      // if all is well, write the MacModels.plist to local disk
      let success: Bool = dictionary.write(toFile: MacModels.localPath, atomically: true)
      self.updateVariables(success: success)
    }

    task.resume()
  }

  func getModelArray() -> [MacModel] {
    return self.modelArray
  }

  func getLastUpdated() -> Date {
    return self.lastUpdated
  }

  func getModels(for identifiers: [String]) -> [MacModel] {
    var models: [MacModel] = []

    for model in self.modelArray where identifiers.contains(model.getModelIdentifier()) {
      models.append(model)
    }

    return models
  }
}
