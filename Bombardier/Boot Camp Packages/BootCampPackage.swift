//
//  BootCampPackage
//  Bombardier
//
//  Created by Nindi Gill on 18/5/19.
//  Copyright © 2019 Nindi Gill. All rights reserved.
//

import Cocoa

class BootCampPackage: NSObject {
  
  private var name = ""
  private var size = 0
  private var date = Date()
  private var url = ""
  private var modelIdentifiers = [String]()
  
  convenience init(name: String, size: Int, date: Date, url: String, modelIdentifiers: [String]) {
    self.init()
    self.name = name
    self.size = size
    self.date = date
    self.url = url
    self.modelIdentifiers = modelIdentifiers
  }
  
  func getName() -> String {
    return self.name
  }
  
  func getSize() -> Int {
    return self.size
  }
  
  func getDate() -> Date {
    return self.date
  }
  
  func getURL() -> String {
    return self.url
  }
  
  func getModelIdentifiers() -> [String] {
    return self.modelIdentifiers
  }
  
  override var description: String {
    return "\(self.name) (\(self.size) bytes) - (\(self.date)\n\tSupported Model Identifiers: \(self.modelIdentifiers)"
  }
}
