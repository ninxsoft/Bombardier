//
//  BootCampPackage
//  Bombardier
//
//  Created by Nindi Gill on 18/5/19.
//  Copyright © 2019 Nindi Gill. All rights reserved.
//

import Cocoa

class BootCampPackage: NSObject {
  private var name: String = ""
  private var size: Int = 0
  private var date: Date = Date()
  private var url: String = ""
  private var modelIdentifiers: [String] = []

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

  func getSizeString() -> String {
    let size: Float = Float(getSize()) / 1000 / 1000
    let string: String = String(format: "%.1f MB", size)
    return string
  }

  func getDate() -> Date {
    return self.date
  }

  func getDateString() -> String {
    let date: Date = getDate()
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    let string: String = dateFormatter.string(from: date)
    return string
  }

  func getURL() -> String {
    return self.url
  }

  func getModelIdentifiers() -> [String] {
    return self.modelIdentifiers
  }
}
