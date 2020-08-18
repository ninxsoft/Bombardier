//
//  Data+Extension.swift
//  Bombardier
//
//  Created by Nindi Gill on 11/7/20.
//

import Foundation

extension Data {

  var downloadsDirectoryURL: URL {

    var isStale: Bool = false
    var url: URL = URL(fileURLWithPath: Preferences.defaultDownloadsDirectory)

    do {
      url = try URL(resolvingBookmarkData: self, bookmarkDataIsStale: &isStale)
    } catch {
      print(error)
    }

    return url
  }
}
