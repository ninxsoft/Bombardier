//
//  MacModel.swift
//  Bombardier
//
//  Created by Nindi Gill on 18/5/19.
//  Copyright © 2019 Nindi Gill. All rights reserved.
//

import Cocoa

class MacModel: NSObject {

  static let imagePathPrefix = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/"
  private var modelIdentifier = ""
  private var marketingName = ""
  private var imagePath = ""

  convenience init(modelIdentifier: String, marketingName: String, imagePath: String) {
    self.init()
    self.modelIdentifier = modelIdentifier
    self.marketingName = marketingName
    self.imagePath = MacModel.imagePathPrefix + imagePath
  }

  func getModelIdentifier() -> String {
    return self.modelIdentifier
  }

  func getMarketingName() -> String {
    return self.marketingName
  }

  func getImagePath() -> String {
    return self.imagePath
  }

  override var description: String {
    return "\(self.marketingName) (\(self.modelIdentifier))"
  }
}
