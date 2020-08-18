//
//  Extracter.swift
//  Bombardier
//
//  Created by Nindi Gill on 8/7/20.
//

import Foundation

class Extracter: NSObject, ObservableObject {

  static let shared: Extracter = Extracter()
  @Published var finished: Bool = false
  @Published var failed: Bool = false
  var task: Process?

  func extract(_ package: Package, to directory: String) {

    let directoryPath: String = NSTemporaryDirectory() + package.name
    let packagePath: String = NSTemporaryDirectory() + package.name + ".pkg"
    let payloadPath: String = directoryPath + "/Payload"
    let dmgPath: String = directoryPath + "/Library/Application Support/BootCamp/WindowsSupport.dmg"
    let downloadPath: String = directory + "/" + package.name + ".dmg"
    finished = false
    failed = false

    guard removeDirectory(directoryPath) else {
      finish(failed: true)
      return
    }

    do {
      try FileManager.default.createDirectory(atPath: directoryPath,
                                              withIntermediateDirectories: false,
                                              attributes: nil)

      DispatchQueue.global(qos: .background).async {
        // extract the package (which is actually a xar), then extract the Payload (which is actually a tar)
        guard self.shell("xar", "-xf", packagePath, "-C", directoryPath),
              self.shell("tar", "-xf", payloadPath, "-C", directoryPath) else {
          _ = self.removeFile(packagePath)
          _ = self.removeDirectory(directoryPath)
          self.finish(failed: true)
          return
        }

        var isDirectory: ObjCBool = ObjCBool(false)

        do {
          if !FileManager.default.fileExists(atPath: directory, isDirectory: &isDirectory) {
            try FileManager.default.createDirectory(atPath: directory,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
          }

          try FileManager.default.moveItem(atPath: dmgPath, toPath: downloadPath)
          self.finish(failed: false)
        } catch {
          print(error)
          self.finish(failed: true)
        }

        _ = self.removeFile(packagePath)
        _ = self.removeDirectory(directoryPath)
      }
    } catch {
      print(error)
      self.finish(failed: true)
      _ = removeFile(packagePath)
      _ = removeDirectory(directoryPath)
    }
  }

  private func finish(failed: Bool) {

    DispatchQueue.main.async {
      self.finished = true
      self.failed = failed
    }
  }

  private func removeFile(_ path: String) -> Bool {

    do {
      if FileManager.default.fileExists(atPath: path) {
        try FileManager.default.removeItem(atPath: path)
      }

      return true
    } catch {
      print(error)
      return false
    }
  }

  private func removeDirectory(_ path: String) -> Bool {

    var isDirectory: ObjCBool = ObjCBool(false)

    do {
      if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) {
        try FileManager.default.removeItem(atPath: path)
      }

      return true
    } catch {
      print(error)
      return false
    }
  }

  private func shell(_ args: String...) -> Bool {
    let process: Process = Process()
    process.launchPath = "/usr/bin/env"
    process.arguments = args
    process.launch()
    process.waitUntilExit()
    self.task = process
    return process.terminationStatus == 0
  }

  func cancel() {
    task?.terminate()
    finish(failed: true)
  }
}
