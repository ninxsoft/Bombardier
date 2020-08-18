//
//  Images.swift
//  Bombardier
//
//  Created by Nindi Gill on 7/7/20.
//

import Cocoa

class Images {

  static let shared: Images = Images()
  private static let modelPath: String = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/"
  private static let packagePath: String = "/System/Library/CoreServices/Installer.app/Contents/Resources/package.icns"
  // swiftlint:disable:next line_length
  private static let dmgPath: String = "/System/Library/CoreServices/DiskImageMounter.app/Contents/Resources/diskcopy-doc.icns"
  private var modelsArray: [(name: String, image: NSImage)] = []

  init() {

    do {
      let names: [String] = try FileManager.default.contentsOfDirectory(atPath: Images.modelPath)

      for name in names where name.contains("imac") ||
                              name.contains("macpro") ||
                              name.contains("macmini") ||
                              name.contains("macbook") {

        if let image: NSImage = NSImage(contentsOfFile: Images.modelPath + name) {
          let tuple: (name: String, image: NSImage) = (name: name, image: image)
          modelsArray.append(tuple)
        }
      }
    } catch {
      print(error)
    }
  }

  func model(width: CGFloat, height: CGFloat) -> NSImage {
    if let image: NSImage = NSImage(contentsOfFile: Images.modelPath + "com.apple.imacpro-2017.icns"),
       let resizedImage: NSImage = image.resized(width: width, height: height) {
      return resizedImage
    } else {
      let image: NSImage = NSImage(systemSymbolName: "desktopcomputer", accessibilityDescription: nil)!
      let resizedImage: NSImage = image.resized(width: width, height: height)!
      return resizedImage
    }
  }

  func modelImage(for name: String, width: CGFloat, height: CGFloat) -> NSImage {

    for model in modelsArray where model.name == name {

      if let resizedImage: NSImage = model.image.resized(width: width, height: height) {
        return resizedImage
      }
    }

    let systemSymbolName: String = name.contains("macbook") ? "laptopcomputer" : "desktopcomputer"
    let image: NSImage = NSImage(systemSymbolName: systemSymbolName, accessibilityDescription: nil)!
    let resizedImage: NSImage = image.resized(width: width, height: height)!
    return resizedImage
  }

  func package(width: CGFloat, height: CGFloat) -> NSImage {
    if let image: NSImage = NSImage(contentsOfFile: Images.packagePath),
       let resizedImage: NSImage = image.resized(width: width, height: height) {
      return resizedImage
    } else {
      let image: NSImage = NSImage(systemSymbolName: "archivebox", accessibilityDescription: nil)!
      let resizedImage: NSImage = image.resized(width: width, height: height)!
      return resizedImage
    }
  }

  func dmg(width: CGFloat, height: CGFloat) -> NSImage {
    if let image: NSImage = NSImage(contentsOfFile: Images.dmgPath),
       let resizedImage: NSImage = image.resized(width: width, height: height) {
      return resizedImage
    } else {
      let image: NSImage = NSImage(systemSymbolName: "archivebox", accessibilityDescription: nil)!
      let resizedImage: NSImage = image.resized(width: width, height: height)!
      return resizedImage
    }
  }
}
