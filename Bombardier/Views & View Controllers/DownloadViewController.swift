//
//  DownloadViewController.swift
//  Bombardier
//
//  Created by Nindi Gill on 18/5/19.
//  Copyright © 2019 Nindi Gill. All rights reserved.
//

import Cocoa

class DownloadViewController: NSViewController {

  var package: BootCampPackage = BootCampPackage()
  var session: URLSession = URLSession()
  var success: Bool = false
  @IBOutlet var textField: NSTextField?
  @IBOutlet var progressIndicator: NSProgressIndicator?
  @IBOutlet var progressTextField: NSTextField?
  @IBOutlet var button: NSButton?

  override func viewWillAppear() {
    self.download()
  }

  @IBAction func buttonClicked(sender: NSButton) {
    self.session.invalidateAndCancel()
    self.view.window?.sheetParent?.endSheet(self.view.window!, returnCode: self.success ? .OK : .cancel)
  }

  private func download() {

    self.textField?.stringValue = "Boot Camp Package \(self.package.getName()): Downloading..."
    self.updateProgress(downloaded: 0, total: Int64(self.package.getSize()))

    guard let url: URL = URL(string: self.package.getURL()) else {
      self.textField?.stringValue = "Boot Camp Package \(self.package.getName()): Downloading Failed!"
      self.progressIndicator?.stopAnimation(self)
      self.button?.title = "Close"
      return
    }

    let sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default
    sessionConfiguration.timeoutIntervalForRequest = 5.0
    self.session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: OperationQueue())
    let task: URLSessionDownloadTask = self.session.downloadTask(with: url)
    task.resume()
  }

  private func updateProgress(downloaded: Int64, total: Int64) {
    let downloadedFloat: Float = Float(downloaded) / 1000.0 / 1000.0
    let totalFloat: Float = Float(total) / 1000.0 / 1000.0
    let percentage: Float = downloadedFloat / totalFloat * 100.0
    let string: String = String(format: "%.1f MB of %.1f MB (%.1f%%)", downloadedFloat, totalFloat, percentage)

    DispatchQueue.main.async {
      self.progressIndicator?.doubleValue = Double(percentage)
      self.progressTextField?.stringValue = string
    }
  }

  private func cleanupTempDirectory(packagePath: String, directoryPath: String) -> Bool {

    do {
      if FileManager.default.fileExists(atPath: packagePath) {
        try FileManager.default.removeItem(atPath: packagePath)
      }

      var isDirectory: ObjCBool = ObjCBool(false)

      if FileManager.default.fileExists(atPath: directoryPath, isDirectory: &isDirectory) {
        try FileManager.default.removeItem(atPath: directoryPath)
      }

      return true
    } catch {
      print(error)
      return false
    }
  }

  // executes a shell command, returns true if executed successfully
  private func shell(_ args: String...) -> Bool {
    let task: Process = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus == 0
  }
}

extension DownloadViewController: URLSessionDownloadDelegate {

  func urlSession(_ session: URLSession,
                  downloadTask: URLSessionDownloadTask,
                  didWriteData bytesWritten: Int64,
                  totalBytesWritten: Int64,
                  totalBytesExpectedToWrite: Int64) {

    if totalBytesExpectedToWrite > 0 {
      self.updateProgress(downloaded: totalBytesWritten, total: totalBytesExpectedToWrite)
    }
  }

  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

    let packagePath: String = NSTemporaryDirectory() + self.package.getName() + ".pkg"
    let directoryPath: String = NSTemporaryDirectory() + self.package.getName()
    let payloadPath: String = directoryPath + "/" + "Payload"
    let dmgPath: String = directoryPath + "/Library/Application Support/BootCamp/WindowsSupport.dmg"
    let downloadPath: String = MainViewController.downloadPath + "/" + self.package.getName() + ".dmg"

    DispatchQueue.main.async {
      self.textField?.stringValue = "Boot Camp Package \(self.package.getName()): Extracting..."
      self.progressIndicator?.isIndeterminate = true
    }

    // ensure no package or extracted directory exists before starting
    guard self.cleanupTempDirectory(packagePath: packagePath, directoryPath: directoryPath) else {

      DispatchQueue.main.async {
        self.textField?.stringValue = "Boot Camp Package \(self.package.getName()): Extracting Failed!"
        self.progressIndicator?.stopAnimation(self)
      }

      return
    }

    do {
      try FileManager.default.moveItem(atPath: location.path, toPath: packagePath)
      try FileManager.default.createDirectory(atPath: directoryPath,
                                              withIntermediateDirectories: false,
                                              attributes: nil)

      // extract the package (which is actually a xar), then extract the Payload (which is actually a tar)
      guard self.shell("xar", "-xf", packagePath, "-C", directoryPath),
        self.shell("tar", "-xf", payloadPath, "-C", directoryPath) else {

          _ = self.cleanupTempDirectory(packagePath: packagePath, directoryPath: directoryPath)

          DispatchQueue.main.async {
            self.textField?.stringValue = "Boot Camp Package \(self.package.getName()): Extracting Failed!"
            self.progressIndicator?.stopAnimation(self)
          }

          return
      }

      var isDirectory: ObjCBool = ObjCBool(false)

      if !FileManager.default.fileExists(atPath: MainViewController.downloadPath, isDirectory: &isDirectory) {
        try FileManager.default.createDirectory(atPath: MainViewController.downloadPath,
                                                withIntermediateDirectories: false,
                                                attributes: nil)
      }

      // move the dmg from temp to the download folder
      try FileManager.default.moveItem(atPath: dmgPath, toPath: downloadPath)
      _ = self.cleanupTempDirectory(packagePath: packagePath, directoryPath: directoryPath)
      NSWorkspace.shared.selectFile(downloadPath, inFileViewerRootedAtPath: "")
      self.success = true
    } catch {
      print(error)
      _ = self.cleanupTempDirectory(packagePath: packagePath, directoryPath: directoryPath)
    }
  }

  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

    DispatchQueue.main.async {

      if let downloadError: Error = error {
        print(downloadError)
        self.textField?.stringValue = "Boot Camp Package \(self.package.getName()): Downloading Failed!"
      } else {
        self.textField?.stringValue = "Boot Camp Package \(self.package.getName()): Extracting Completed!"
      }

      self.progressIndicator?.stopAnimation(self)
      self.button?.title = "Close"
    }
  }
}
