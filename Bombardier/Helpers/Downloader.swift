//
//  Download.swift
//  Bombardier
//
//  Created by Nindi Gill on 8/7/20.
//

import Foundation

class Downloader: NSObject, ObservableObject {

    static let shared: Downloader = Downloader()
    @Published var finished: Bool = false
    @Published var failed: Bool = false
    var totalBytesWritten: CGFloat = 0
    var package: Package = .example
    var task: URLSessionDownloadTask?

    func download(package: Package) {

        self.package = package

        guard let url: URL = URL(string: package.urlPath) else {
            return
        }

        finished = false
        failed = false
        totalBytesWritten = 0

        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5.0
        let session: URLSession = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
        task = session.downloadTask(with: url)
        task?.resume()
    }

    func cancel() {
        task?.cancel()
        finish(failed: true)
    }

    private func finish(failed: Bool) {

        DispatchQueue.main.async {
            self.finished = true
            self.failed = failed
        }
    }
}

extension Downloader: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.totalBytesWritten = CGFloat(totalBytesWritten)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        let packagePath: String = NSTemporaryDirectory() + package.name + ".pkg"

        do {
            try FileManager.default.moveItem(atPath: location.path, toPath: packagePath)
        } catch {
            print(error.localizedDescription)
        }

        finish(failed: false)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

        guard let error: Error = error else {
            return
        }

        print(error)
        finish(failed: true)
    }
}
