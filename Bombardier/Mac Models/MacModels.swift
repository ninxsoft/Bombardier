//
//  MacModels.swift
//  Bombardier
//
//  Created by Nindi Gill on 18/5/19.
//  Copyright © 2019 Nindi Gill. All rights reserved.
//

import Cocoa

class MacModels: NSObject {
  
  static let remotePath = "https://raw.githubusercontent.com/ninxsoft/Bombardier/master/MacModels.plist"
  static let directoryPath = NSHomeDirectory() + "/Library/Application Support/Bombardier"
  static let localPath = NSHomeDirectory() + "/Library/Application Support/Bombardier/MacModels.plist"
  private var modelArray = [MacModel]()
  private var lastUpdated = Date()
  
  func update() {
    self.downloadUpdate()
  }
  
  private func downloadUpdate() {
    
    var isDirectory = ObjCBool(false)
    // create the download directory if required
    if !FileManager.default.fileExists(atPath: MacModels.directoryPath, isDirectory: &isDirectory) {
      do {
        try FileManager.default.createDirectory(atPath: MacModels.directoryPath, withIntermediateDirectories: false, attributes: nil)
      } catch let error {
        print(error)
      }
    }

    guard let url = URL(string: MacModels.remotePath) else {
      self.updateVariables(success: false)
      return
    }
      
    let task = URLSession.shared.downloadTask(with: url) { tempURL, repsonse, error in

      guard let tempURL = tempURL,
        let dictionary = NSDictionary(contentsOf: tempURL) else {
          self.updateVariables(success: false)
          return
      }

      // if all is well, write the MacModels.plist to local disk
      let success = dictionary.write(toFile: MacModels.localPath, atomically: true)
      self.updateVariables(success: success)
    }
    
    task.resume()
  }
  
  private func updateVariables(success: Bool) {
    
    var dictionary = NSDictionary()
    
    if let dict =  NSDictionary(contentsOfFile: MacModels.localPath) {
      dictionary = dict
    }
    
    if let models = dictionary.object(forKey: "Models") as? NSArray {
      
      self.modelArray.removeAll()
    
      for model in models {
        
        if let modelDictionary = model as? NSDictionary,
          let modelIdentifier = modelDictionary.object(forKey: "ModelIdentifier") as? String,
          let marketingName = modelDictionary.object(forKey: "MarketingName") as? String,
          let imagePath = modelDictionary.object(forKey: "ImagePath") as? String {
          let macModel = MacModel(modelIdentifier: modelIdentifier, marketingName: marketingName, imagePath: imagePath)
          self.modelArray.append(macModel)
        }
      }
    }
    
    if let lastUpdated = dictionary.object(forKey: "LastUpdated") as? Date {
      self.lastUpdated = lastUpdated
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      let name = NSNotification.Name(rawValue: "MacModelsUpdateComplete")
      NotificationCenter.default.post(name: name, object: success)
    }
  }
  
  func getModelArray() -> [MacModel] {
    return self.modelArray
  }
  
  func getLastUpdated() -> Date {
    return self.lastUpdated
  }
  
  override var description: String {
    
    var string = "Last Updated: \(self.lastUpdated)\n"
    
    for model in self.modelArray {
      string.append("\n\(model.description)")
    }
    
    return string
  }
}
